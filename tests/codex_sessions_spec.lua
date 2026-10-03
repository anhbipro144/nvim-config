local Client = require("codex_sessions.client").Client
local Sessions = require("codex_sessions.sessions")
local UI = require("codex_sessions.ui")
local Util = require("codex_sessions.util")
local Limits = require("codex_sessions.limits")

local function test(name, callback)
  local ok, err = pcall(callback)
  assert(ok, name .. ": " .. tostring(err))
end

local function fake_client()
  local sent = {}
  local callbacks = {}
  local client = {
    request = function(_, method, params, callback)
      table.insert(sent, { method = method, params = params })
      table.insert(callbacks, callback)
    end,
  }
  return client, sent, callbacks
end

test("JSON-RPC response routing", function()
  local sent = {}
  local callback
  local client = Client.new({
    jobstart = function(_, opts) client_opts = opts; return 1 end,
    chansend = function(_, line) table.insert(sent, vim.json.decode(line)); return 1 end,
    jobstop = function() end,
  })
  client:request("thread/list", {}, function(result, err) callback = { result, err } end)
  assert(sent[1].method == "initialize")
  client:_on_stdout({ vim.json.encode({ id = 1, result = { codexHome = "/tmp" } }) .. "\n" })
  assert(sent[2].method == "initialized")
  assert(sent[3].method == "thread/list")
  client:_on_stdout({ vim.json.encode({ id = 2, result = { data = {} } }) .. "\n" })
  assert(callback[1].data ~= nil and callback[2] == nil)
end)

test("malformed JSON is reported", function()
  local malformed
  local client = Client.new({ on_protocol_error = function(message) malformed = message end })
  client:_on_stdout({ "not-json\n" })
  assert(malformed == "malformed JSON from app-server")
end)

test("process exit fails pending requests", function()
  local callback
  local client = Client.new({ jobstart = function() return 1 end, chansend = function() return 1 end })
  client:request("thread/list", {}, function(_, err) callback = err end)
  client:_on_exit(1, 1, "SIGTERM")
  assert(callback and callback.message == "app-server exited unexpectedly")
end)

test("stopping app-server waits for exit without killing a lazy restart", function()
  local started, stopped, sent, ready = 0, nil, {}, false
  local client = Client.new({
    jobstart = function() started = started + 1; return started end,
    chansend = function(id, line) sent[#sent + 1] = { job = id, message = vim.json.decode(line) }; return 1 end,
    jobstop = function(id) stopped = id; return 1 end,
  })
  client:start()
  client:_on_stdout({ vim.json.encode({ id = 1, result = {} }) .. "\n" })
  client:stop(function() ready = true end)
  assert(stopped == 1 and not ready)
  client:request("thread/list", {}, function() end)
  assert(started == 2 and client.state == "starting")
  client:_on_exit(1, 0, "exit")
  assert(ready and client.state == "starting")
  client:_on_stdout({ vim.json.encode({ id = 2, result = {} }) .. "\n" })
  assert(client.state == "ready" and sent[#sent].message.method == "thread/list")
end)

test("thread normalization", function()
  local row = Sessions.normalize({ id = "id", name = "name", cwd = "/tmp", source = "cli", status = { type = "notLoaded" }, updatedAt = 10 }, true)
  assert(row.id == "id" and row.name == "name" and row.archived and row.status.type == "notLoaded")
end)

test("Codex limits use the supported account RPC and all reported buckets", function()
  local client, sent, callbacks = fake_client()
  local rows
  Limits.read(client, function(value) rows = value end)
  assert(sent[1].method == "account/rateLimits/read" and vim.tbl_isempty(sent[1].params))
  callbacks[1]({
    rateLimits = { limitId = "codex", primary = { usedPercent = 99 } },
    rateLimitsByLimitId = {
      codex = { limitId = "codex", primary = { usedPercent = 25, windowDurationMins = 300, resetsAt = 1730947200 } },
      codex_other = { limitId = "codex_other", secondary = { usedPercent = 42, windowDurationMins = 10080 } },
    },
  })
  assert(#rows == 2 and rows[1].primary.used_percent == 25 and rows[2].secondary.used_percent == 42)
  local message = Limits.format(rows)
  assert(message:find("5h: 75%% left") and message:find("1w: 58%% left"))
  assert(Limits.format({ { name = "codex", primary = { used_percent = 0, duration_mins = 300 } } }):find("100%% left"))
  assert(Limits.normalize({ rateLimits = { primary = { usedPercent = 9 } } })[1].primary.used_percent == 9)
end)

test("CodeCompanion exposes a limits action without replacing Copilot stats", function()
  local old_config = package.loaded["codecompanion.config"]
  local chat = { keymaps = { copilot_stats = { modes = { n = "gS" } } }, slash_commands = {} }
  package.loaded["codecompanion.config"] = { interactions = { chat = chat } }
  local ok, err = pcall(function()
    local extension = require("codecompanion._extensions.codex_sessions")
    extension.setup({})
    assert(chat.keymaps.codex_limits.modes.n == "gL")
    assert(chat.keymaps.copilot_stats.modes.n == "gS")
    assert(type(extension.exports.limits) == "function")
  end)
  package.loaded["codecompanion.config"] = old_config
  assert(ok, err)
end)

test("limits open a dismissible popup instead of a notification", function()
  local manager = require("codex_sessions")
  local old_client, old_notify = manager._client, vim.notify
  local notices = 0
  manager._client = { request = function(_, _, _, callback)
    callback({ rateLimits = { primary = { usedPercent = 25, windowDurationMins = 300 } } })
  end }
  vim.notify = function() notices = notices + 1 end
  local win
  local ok, err = pcall(function()
    manager.limits()
    win = vim.api.nvim_get_current_win()
    assert(vim.api.nvim_win_get_config(win).relative == "editor")
    assert(table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)):find("75%% left"))
    assert(notices == 0)
    manager.limits()
    assert(not vim.api.nvim_win_is_valid(win))
    win = vim.api.nvim_get_current_win()
  end)
  if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  manager._client, vim.notify = old_client, old_notify
  assert(ok, err)
end)

test("rename and fork requests", function()
  local client, sent, callbacks = fake_client()
  local store = Sessions.new(client)
  store:rename("a", "new name", function() end)
  assert(sent[1].method == "thread/name/set" and sent[1].params.threadId == "a" and sent[1].params.name == "new name")
  local forked
  store:fork("a", {}, function(row) forked = row end)
  assert(sent[2].method == "thread/fork" and sent[2].params.excludeTurns == true)
  callbacks[2]({ thread = { id = "fork-id", cwd = "/tmp", updatedAt = 1 } })
  assert(forked.id == "fork-id")
end)

test("lifecycle requests always carry a thread ID", function()
  local client, sent = fake_client()
  local store = Sessions.new(client)
  store:archive("thread-1", function() end)
  store:unarchive("thread-1", function() end)
  store:delete("thread-1", function() end)
  assert(sent[1].method == "thread/archive" and sent[1].params.threadId == "thread-1")
  assert(sent[2].method == "thread/unarchive" and sent[2].params.threadId == "thread-1")
  assert(sent[3].method == "thread/delete" and sent[3].params.threadId == "thread-1")
  local rejected
  store:archive(nil, function(_, err) rejected = err end)
  assert(rejected.message:find("missing thread ID") and #sent == 3)
end)

test("picker archive action passes the selected thread ID", function()
  local client, sent = fake_client()
  UI.setup({ sessions = Sessions.new(client), config = { picker = { backend = "none", current_cwd_only = true }, confirm_delete = true } })
  UI.toggle_archive({ id = "selected-thread", archived = false })
  assert(sent[1].method == "thread/archive" and sent[1].params.threadId == "selected-thread")
end)

test("picker rows stay on one line", function()
  local row = Util.format_session({ id = "thread-1", preview = "first line\nsecond line", cwd = "/tmp", updated_at = os.time() }, 100)
  assert(not row:find("\n") and row:find("first line second line", 1, true))
end)

test("active and archived filtering", function()
  local seen
  local client = { request = function(_, _, params, callback) seen = params; callback({ data = {} }) end }
  local store = Sessions.new(client)
  store:list({ archived = true, current_cwd_only = true, cwd = "/tmp" }, function() end)
  assert(seen.archived == true and seen.cwd == "/tmp")
end)

test("listing includes state-DB-only forks without losing scanned sessions", function()
  local client, sent, callbacks = fake_client()
  local rows
  Sessions.new(client):list({ archived = false, current_cwd_only = true, cwd = "/project" }, function(result)
    rows = result
  end)
  assert(sent[1].method == "thread/list" and sent[1].params.cwd == "/project")
  assert(sent[1].params.useStateDbOnly == nil)
  callbacks[1]({ data = { { id = "old", updatedAt = 1 } }, nextCursor = "more" })
  assert(sent[2].params.cursor == "more" and sent[2].params.useStateDbOnly == nil)
  callbacks[2]({ data = { { id = "shared", updatedAt = 2 } } })
  assert(sent[3].params.cursor == nil and sent[3].params.useStateDbOnly == true)
  callbacks[3]({ data = { { id = "shared", updatedAt = 3 }, { id = "fork", updatedAt = 4 } } })
  assert(#rows == 3 and rows[1].id == "fork" and rows[2].id == "shared" and rows[3].id == "old")
  assert(rows[2].updated_at == 3)
end)

test("delete confirmation requires the destructive choice", function()
  local selected
  local deleted = false
  UI.confirm_delete({ id = "abcdefghi", name = "test" }, function(_, _, callback) callback("Cancel") end, function() deleted = true end, true)
  assert(not deleted)
  UI.confirm_delete({ id = "abcdefghi", name = "test" }, function(_, _, callback) selected = true; callback("Delete permanently") end, function() deleted = true end, true)
  assert(selected and deleted)
end)

test("bulk delete confirms IDs and reports partial failures", function()
  local client, sent, callbacks = fake_client()
  UI.setup({ sessions = Sessions.new(client), config = { picker = { backend = "none", current_cwd_only = true }, confirm_delete = false } })
  local old_select, old_refresh, old_notify = vim.ui.select, UI.refresh, vim.notify
  local choose, prompt, refreshed, notices = nil, nil, 0, {}
  vim.ui.select = function(_, opts, callback) prompt = opts.prompt; choose = callback end
  UI.refresh = function() refreshed = refreshed + 1 end
  vim.notify = function(message) notices[#notices + 1] = message end

  local ok, err = pcall(function()
    UI.bulk_delete({})
    assert(choose == nil)
    local rows = { { id = "thread-a-1234", name = "A" }, { id = "thread-b-5678", name = "B" } }
    UI.bulk_delete(rows)
    assert(prompt:find("thread-a-1234", 1, true) and prompt:find("thread-b-5678", 1, true))
    choose("Cancel")
    assert(#sent == 0)

    UI.bulk_delete(rows)
    choose("Delete 2 permanently")
    assert(#sent == 1 and sent[1].method == "thread/delete" and sent[1].params.threadId == "thread-a-1234")
    callbacks[1]({}, nil)
    assert(#sent == 2 and sent[2].params.threadId == "thread-b-5678")
    callbacks[2](nil, { message = "thread active" })
    assert(refreshed == 1 and notices[1]:find("deleted 1 of 2", 1, true))
    assert(notices[2]:find("thread-b-5678: thread active", 1, true))
  end)
  vim.ui.select, UI.refresh, vim.notify = old_select, old_refresh, old_notify
  assert(ok, err)
end)

test("CodeCompanion picker hands Enter the exact selected session", function()
  local chosen
  local old_select = vim.ui.select
  UI.setup({
    sessions = { list = function(_, _, callback) callback({ { id = "chosen-thread", cwd = vim.fn.getcwd() } }) end },
    config = { picker = { backend = "none", current_cwd_only = true } },
  })
  vim.ui.select = function(choices, _, callback) callback(choices[1], 1) end
  local ok, err = pcall(function()
    UI.open({ on_select = function(session) chosen = session.id end })
    assert(chosen == "chosen-thread")
  end)
  vim.ui.select = old_select
  assert(ok, err)
end)

test("CodeCompanion extension opens a fresh Codex chat with the selected ID", function()
  local modules = {
    "codecompanion",
    "codecompanion.interactions.chat.helpers",
    "codecompanion.utils.async",
    "codecompanion.utils",
    "codecompanion.interactions.chat.acp.commands",
    "codecompanion.interactions.chat.acp.render",
  }
  local old = {}
  for _, name in ipairs(modules) do old[name] = package.loaded[name] end
  local old_select = vim.ui.select
  local bufnr = vim.api.nvim_create_buf(false, true)
  local args, loaded_id, loaded_title, chat_count, choices = nil, nil, nil, 0, nil
  package.loaded[modules[1]] = {
    chat = function(opts)
      args = opts
      chat_count = chat_count + 1
      return {
        bufnr = bufnr,
        cycle = 1,
        id = "new-chat",
        acp_connection = {
          is_ready = function() return true end,
          can_load_session = function() return true end,
          load_session = function(self, id) self.session_id = id; loaded_id = id; return true end,
        },
        set_title = function(self, title) self.title = title; loaded_title = title end,
      }
    end,
  }
  package.loaded[modules[2]] = { create_acp_connection = function(_, callback) callback() end }
  package.loaded[modules[3]] = { sync = function(callback) return callback end }
  package.loaded[modules[4]] = { notify = function() end, fire = function() end }
  package.loaded[modules[5]] = { link_buffer_to_session = function() end }
  package.loaded[modules[6]] = { restore_session = function() end }

  local ok, err = pcall(function()
    require("codecompanion._extensions.codex_sessions").load_session({ id = "chosen-thread", name = "Named", cwd = vim.fn.getcwd() })
    assert(args.params.adapter == "codex" and args.stop_context_insertion)
    assert(loaded_id == "chosen-thread" and loaded_title == "Named")
    vim.ui.select = function(items, _, callback) choices = items; callback("Cancel") end
    require("codecompanion._extensions.codex_sessions").load_session({ id = "other-thread", cwd = "/tmp" })
    assert(chat_count == 1 and choices[1]:find("/tmp", 1, true))
  end)
  vim.ui.select = old_select
  for _, name in ipairs(modules) do package.loaded[name] = old[name] end
  vim.api.nvim_buf_delete(bufnr, { force = true })
  assert(ok, err)
end)

test("ACP restore uses the exact ID and rejects a fallback session", function()
  local old_utils = package.loaded["codecompanion.utils"]
  local old_commands = package.loaded["codecompanion.interactions.chat.acp.commands"]
  local old_render = package.loaded["codecompanion.interactions.chat.acp.render"]
  local notice
  local event, linked, rendered
  package.loaded["codecompanion.utils"] = {
    notify = function(message) notice = message end,
    fire = function(name, data) event = { name = name, data = data } end,
  }
  package.loaded["codecompanion.interactions.chat.acp.commands"] = {
    link_buffer_to_session = function(_, id) linked = id end,
  }
  package.loaded["codecompanion.interactions.chat.acp.render"] = {
    restore_session = function(_, updates) rendered = updates end,
  }
  local extension = require("codecompanion._extensions.codex_sessions")
  local bufnr = vim.api.nvim_create_buf(false, true)
  local chat = {
    cycle = 1,
    bufnr = bufnr,
    id = 9,
    set_title = function(self, title) self.title = title end,
    acp_connection = {
      is_ready = function() return true end,
      can_load_session = function() return true end,
      load_session = function(self) self.session_id = "new-empty-thread"; return true end,
    },
  }
  local ok, err = pcall(function()
    assert(extension.restore_session(chat, { sessionId = "chosen-thread" }) == false)
    assert(notice:find("chosen-thread", 1, true))
    assert(linked == nil and rendered == nil)
    assert(vim.b[bufnr].codecompanion_tab_title == nil)

    chat.acp_connection.load_session = function(self, id, opts)
      self.session_id = id
      opts.on_session_update({ sessionUpdate = "user_message_chunk" })
      return true
    end
    assert(extension.restore_session(chat, { sessionId = "chosen-thread", title = "Named" }) == true)
    assert(linked == "chosen-thread" and rendered[1].sessionUpdate == "user_message_chunk")
    assert(chat.title == "Named" and vim.b[bufnr].codecompanion_tab_title == "Named")
    assert(event.name == "ACPChatRestored" and event.data.session_id == "chosen-thread")
  end)
  package.loaded["codecompanion.utils"] = old_utils
  package.loaded["codecompanion.interactions.chat.acp.commands"] = old_commands
  package.loaded["codecompanion.interactions.chat.acp.render"] = old_render
  vim.api.nvim_buf_delete(bufnr, { force = true })
  assert(ok, err)
end)

test("CodeCompanion /fork opens the returned ID after manager releases its writer", function()
  local extension = require("codecompanion._extensions.codex_sessions")
  local old_config = package.loaded["codecompanion.config"]
  local old_manager = package.loaded["codex_sessions"]
  local old_notify, old_load = vim.notify, extension.load_session
  local config = { interactions = { chat = { keymaps = {}, slash_commands = {} } } }
  local source = { adapter = { name = "codex" }, acp_connection = { session_id = "source-id" } }
  local fork_callback, stop_callback, opened, notices, calls = nil, nil, nil, {}, 0
  package.loaded["codecompanion.config"] = config
  package.loaded["codex_sessions"] = {
    fork = function(id, opts, callback)
      assert(id == "source-id" and opts.exclude_turns == true)
      calls = calls + 1
      fork_callback = callback
    end,
    shutdown = function(callback) stop_callback = callback end,
  }
  vim.notify = function(message) notices[#notices + 1] = message end
  extension.load_session = function(session) opened = session end

  local ok, err = pcall(function()
    extension.setup({})
    assert(config.interactions.chat.slash_commands.fork.callback == extension.fork_current)
    extension.fork_current({ adapter = { name = "other" }, acp_connection = source.acp_connection })
    assert(calls == 0 and notices[#notices]:find("only available", 1, true))
    source.current_request = true
    extension.fork_current(source)
    assert(calls == 0 and notices[#notices]:find("stop the current response", 1, true))
    source.current_request = nil
    extension.fork_current(source)
    fork_callback(nil, { message = "fork rejected" })
    assert(not stop_callback and notices[#notices]:find("fork rejected", 1, true))
    extension.fork_current(source)
    fork_callback({ id = "new-fork-id", cwd = "/tmp" })
    assert(not opened and stop_callback and source.acp_connection.session_id == "source-id")
    stop_callback()
    assert(opened.id == "new-fork-id" and opened.cwd == vim.fn.getcwd())
    assert(source.acp_connection.session_id == "source-id")
  end)
  package.loaded["codecompanion.config"] = old_config
  package.loaded["codex_sessions"] = old_manager
  vim.notify, extension.load_session = old_notify, old_load
  assert(ok, err)
end)

test("CodeCompanion /rename persists Codex names and preserves HTTP titles", function()
  local extension = require("codecompanion._extensions.codex_sessions")
  local old_config = package.loaded["codecompanion.config"]
  local old_manager = package.loaded["codex_sessions"]
  local old_utils = package.loaded["codecompanion.utils"]
  local old_input, old_notify = vim.ui.input, vim.notify
  local config = { interactions = { chat = { keymaps = {}, slash_commands = {} } } }
  local bufnr = vim.api.nvim_create_buf(false, true)
  local connection = { session_id = "codex-thread" }
  local chat = {
    adapter = { name = "codex", type = "acp" },
    acp_connection = connection,
    bufnr = bufnr,
    set_title = function(self, title) self.title = title end,
  }
  local prompt, answer, rename_callback, renamed, notice
  package.loaded["codecompanion.config"] = config
  package.loaded["codecompanion.utils"] = { notify = function(message) notice = message end }
  package.loaded["codex_sessions"] = {
    get = function(id, callback) assert(id == "codex-thread"); callback({ id = id, name = "Old name" }) end,
    rename = function(id, name, callback) renamed = { id, name }; rename_callback = callback end,
  }
  vim.ui.input = function(opts, callback) prompt = opts; answer = callback end
  vim.notify = function(message) notice = message end

  local ok, err = pcall(function()
    extension.setup({})
    local command = config.interactions.chat.slash_commands.rename
    assert(command.callback == extension.rename_current)
    assert(command.enabled({ adapter = chat.adapter }))
    assert(command.enabled({ adapter = { type = "http" } }))
    assert(not command.enabled({ adapter = { name = "other", type = "acp" } }))

    command.callback(chat)
    assert(prompt.default == "Old name")
    answer("  New name  ")
    assert(renamed[1] == "codex-thread" and renamed[2] == "New name")
    assert(chat.title == nil)
    rename_callback({}, nil)
    assert(chat.title == "New name" and vim.b[bufnr].codecompanion_tab_title == "New name")

    renamed = nil
    command.callback(chat)
    answer("Rejected name")
    rename_callback(nil, { message = "rename rejected" })
    assert(chat.title == "New name" and notice:find("rename rejected", 1, true))
    renamed = nil
    command.callback(chat)
    answer("  ")
    assert(renamed == nil)
    command.callback(chat)
    connection.session_id = "other-thread"
    answer("Not applied")
    assert(renamed == nil and notice:find("session changed", 1, true))

    local http = { adapter = { type = "http" }, title = "HTTP", set_title = chat.set_title }
    command.callback(http)
    assert(prompt.prompt == "Enter title: " and prompt.default == "HTTP")
    answer("Local only")
    assert(http.title == "Local only" and renamed == nil)
  end)
  package.loaded["codecompanion.config"] = old_config
  package.loaded["codex_sessions"] = old_manager
  package.loaded["codecompanion.utils"] = old_utils
  vim.ui.input, vim.notify = old_input, old_notify
  assert(ok, err)
end)

test("CodeCompanion /delete releases its writer before deleting", function()
  local extension = require("codecompanion._extensions.codex_sessions")
  local old_config = package.loaded["codecompanion.config"]
  local old_sessions = package.loaded["codex_sessions"]
  local old_select, old_notify, old_defer = vim.ui.select, vim.notify, vim.defer_fn
  local config = { interactions = { chat = { keymaps = {}, slash_commands = {} } } }
  local selected, prompt, closed, deleted, notice, respond, retry = nil, nil, false, nil, nil, nil, nil
  local bufnr = vim.api.nvim_create_buf(false, true)
  local connection = { session_id = "thread-to-delete" }
  local chat = {
    adapter = { name = "codex" },
    acp_connection = connection,
    bufnr = bufnr,
    close = function() closed = true; connection.session_id = nil end,
  }
  package.loaded["codecompanion.config"] = config
  package.loaded["codex_sessions"] = {
    get = function(id, callback) assert(id == "thread-to-delete"); callback({ id = id, name = "Named" }) end,
    delete = function(id, callback) assert(closed); deleted = id; respond = callback end,
  }
  vim.ui.select = function(_, opts, callback) prompt = opts.prompt; selected = callback end
  vim.notify = function(message) notice = message end
  vim.defer_fn = function(callback, delay) assert(delay == 250); retry = callback end

  local ok, err = pcall(function()
    extension.setup({})
    assert(config.interactions.chat.slash_commands.delete.callback == extension.delete_current)
    extension.delete_current(chat)
    assert(prompt:find("Named", 1, true) and prompt:find("thread-to-delete", 1, true))
    assert(prompt:find("Subagent threads", 1, true))
    selected("Cancel")
    assert(not closed and deleted == nil)
    extension.delete_current(chat)
    selected("Delete permanently")
    assert(closed and deleted == nil and retry)
    retry()
    assert(deleted == "thread-to-delete")
    retry = nil
    respond(nil, { message = "already has an active writer" })
    assert(retry and notice == nil)
    retry()
    respond({}, nil)
    assert(notice:find("session deleted", 1, true))

    closed, deleted, notice, retry = false, nil, nil, nil
    connection.session_id = "thread-to-delete"
    extension.delete_current(chat)
    chat.acp_connection.session_id = "another-thread"
    selected("Delete permanently")
    assert(not closed and deleted == nil and notice:find("chat session changed", 1, true))

    chat.acp_connection.session_id = "thread-to-delete"
    notice = nil
    extension.delete_current(chat)
    selected("Delete permanently")
    retry()
    retry = nil
    respond(nil, { message = "other lifecycle constraint" })
    assert(closed and retry == nil and notice:find("other lifecycle constraint", 1, true))

    closed, notice = false, nil
    connection.session_id = "thread-to-delete"
    extension.delete_current(chat)
    selected("Delete permanently")
    retry()
    retry = nil
    for attempt = 1, 20 do
      respond(nil, { message = "already has an active writer" })
      if attempt < 20 then
        assert(retry)
        retry()
        retry = nil
      end
    end
    assert(retry == nil and notice:find("active writer", 1, true))
  end)
  package.loaded["codecompanion.config"] = old_config
  package.loaded["codex_sessions"] = old_sessions
  vim.ui.select, vim.notify, vim.defer_fn = old_select, old_notify, old_defer
  vim.api.nvim_buf_delete(bufnr, { force = true })
  assert(ok, err)
end)

print("codex_sessions tests: ok")
