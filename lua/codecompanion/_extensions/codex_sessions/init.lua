local Extension = {}

local function notify(message, level)
  vim.notify("Codex Sessions: " .. message, level or vim.log.levels.ERROR)
end

function Extension.restore_session(chat, selected)
  local utils = require("codecompanion.utils")
  if chat.cycle > 1 then
    utils.notify("session loading is only available before submitting a message", vim.log.levels.WARN)
    return false
  end

  local connection = chat.acp_connection
  if not connection or not connection:is_ready() or not connection:can_load_session() then
    utils.notify("Codex ACP session loading is unavailable", vim.log.levels.ERROR)
    return false
  end

  local updates = {}
  local ok = connection:load_session(selected.sessionId, {
    on_session_update = function(update) updates[#updates + 1] = update end,
  })
  if not ok or connection.session_id ~= selected.sessionId then
    utils.notify("Failed to load session " .. selected.sessionId, vim.log.levels.ERROR)
    return false
  end

  require("codecompanion.interactions.chat.acp.commands").link_buffer_to_session(chat.bufnr, selected.sessionId)
  require("codecompanion.interactions.chat.acp.render").restore_session(chat, updates)
  if type(selected.title) == "string" and vim.trim(selected.title) ~= "" then
    chat:set_title(selected.title)
    vim.b[chat.bufnr].codecompanion_tab_title = selected.title
    vim.cmd("redrawstatus")
  end

  utils.fire("ACPChatRestored", {
    bufnr = chat.bufnr,
    id = chat.id,
    session_id = selected.sessionId,
    title = chat.title,
  })
  utils.notify("Resumed session: " .. (selected.title or selected.sessionId), vim.log.levels.INFO)
  return true
end

function Extension.load_session(session)
  if type(session.id) ~= "string" or session.id == "" then
    return notify("missing session ID; refresh the picker")
  end

  local function open_chat()
    local ok, codecompanion = pcall(require, "codecompanion")
    if not ok or type(codecompanion.chat) ~= "function" then
      return notify("CodeCompanion is unavailable")
    end

    local created, chat = pcall(codecompanion.chat, { params = { adapter = "codex" }, stop_context_insertion = true })
    if not created or not chat then return notify("could not create a CodeCompanion chat") end

    local available, helpers = pcall(require, "codecompanion.interactions.chat.helpers")
    if not available or type(helpers.create_acp_connection) ~= "function" then
      return notify("CodeCompanion ACP integration changed; use /resume")
    end

    helpers.create_acp_connection(chat, function()
      if not vim.api.nvim_buf_is_valid(chat.bufnr) then return end
      require("codecompanion.utils.async").sync(function()
        local loaded, err = pcall(Extension.restore_session, chat, {
          sessionId = session.id,
          title = session.name,
        })
        if not loaded then notify("failed to open session: " .. tostring(err)) end
      end)()
    end)
  end

  if session.cwd and session.cwd ~= vim.fn.getcwd() then
    local use_session = "Use session directory (" .. session.cwd .. ")"
    local use_current = "Use current directory (" .. vim.fn.getcwd() .. ")"
    vim.ui.select({ use_session, use_current, "Cancel" }, {
      prompt = "Working directory for resumed session",
    }, function(choice)
      if choice == use_session then
        if vim.fn.isdirectory(session.cwd) == 0 then
          return notify("session cwd no longer exists: " .. session.cwd)
        end
        vim.cmd("tcd " .. vim.fn.fnameescape(session.cwd))
      elseif choice ~= use_current then
        return
      end
      open_chat()
    end)
    return
  end

  open_chat()
end

local function open_manager()
  require("codex_sessions").open({ on_select = Extension.load_session })
end

function Extension.delete_current(chat)
  local connection = chat and chat.acp_connection
  if not chat or not chat.adapter or chat.adapter.name ~= "codex" or not connection then
    return notify("/delete is only available in a Codex ACP chat")
  end
  local id = connection.session_id
  if type(id) ~= "string" or id == "" then return notify("current Codex session has no ID yet") end
  if chat.current_request then return notify("stop the current response before deleting this session") end

  local sessions = require("codex_sessions")
  local util = require("codex_sessions.util")
  sessions.get(id, function(session, err)
    if err then return notify("could not inspect session: " .. util.error_message(err)) end
    if not session then return notify("current Codex session was not found") end
    if not vim.api.nvim_buf_is_valid(chat.bufnr) or connection.session_id ~= id then
      return notify("chat session changed; deletion cancelled")
    end

    local name = (session.name or "(unnamed)"):gsub("%s+", " ")
    local prompt = string.format(
      'Permanently delete Codex session "%s" (%s)?\nThis cannot be undone. Subagent threads will also be deleted.',
      name, id
    )
    vim.ui.select({ "Delete permanently", "Cancel" }, { prompt = prompt }, function(choice)
      if choice ~= "Delete permanently" then return end
      if not vim.api.nvim_buf_is_valid(chat.bufnr) or connection.session_id ~= id or chat.current_request then
        return notify("chat session changed or is busy; deletion cancelled")
      end
      local closed, close_err = pcall(require("codecompanion.tabs").close_chat, chat)
      if not closed then return notify("could not close chat; deletion cancelled: " .. tostring(close_err)) end

      local attempts = 0
      local function delete_after_close()
        attempts = attempts + 1
        sessions.delete(id, function(_, delete_err)
          if not delete_err then return notify("session deleted: " .. id, vim.log.levels.INFO) end
          local message = util.error_message(delete_err)
          if message:find("already has an active writer", 1, true) and attempts < 20 then
            return vim.defer_fn(delete_after_close, 250)
          end
          notify("deletion rejected: " .. message .. " (chat closed; retry from :CodexSessions)")
        end)
      end
      vim.defer_fn(delete_after_close, 250)
    end)
  end)
end

function Extension.fork_current(chat)
  local connection = chat and chat.acp_connection
  if not chat or not chat.adapter or chat.adapter.name ~= "codex" or not connection then
    return notify("/fork is only available in a Codex ACP chat")
  end
  local id = connection.session_id
  if type(id) ~= "string" or id == "" then return notify("current Codex session has no ID yet") end
  if chat.current_request then return notify("stop the current response before forking this session") end

  local manager = require("codex_sessions")
  local util = require("codex_sessions.util")
  manager.fork(id, { exclude_turns = true }, function(fork, err)
    if err then return notify("failed to fork session: " .. util.error_message(err)) end
    if not fork or type(fork.id) ~= "string" or fork.id == "" then
      return notify("Codex returned no fork ID")
    end
    notify("fork created: " .. fork.id, vim.log.levels.INFO)
    -- The manager's app-server owns the new thread until its process exits.
    manager.shutdown(function()
      Extension.load_session({ id = fork.id, name = fork.name, cwd = vim.fn.getcwd() })
    end)
  end)
end

function Extension.rename_current(chat)
  if not chat or not chat.adapter then return notify("/rename requires a chat") end
  if chat.adapter.type == "http" then
    return vim.ui.input({ prompt = "Enter title: ", default = chat.title or "" }, function(input)
      if input then
        chat:set_title(input)
        require("codecompanion.utils").notify("Renamed the chat")
      end
    end)
  end

  local connection = chat.acp_connection
  if chat.adapter.name ~= "codex" or not connection then
    return notify("/rename is only available in a Codex ACP chat")
  end
  local id = connection.session_id
  if type(id) ~= "string" or id == "" then return notify("current Codex session has no ID yet") end

  local manager = require("codex_sessions")
  local util = require("codex_sessions.util")
  manager.get(id, function(session, err)
    if err then return notify("could not inspect session: " .. util.error_message(err)) end
    if not session then return notify("current Codex session was not found") end
    if not vim.api.nvim_buf_is_valid(chat.bufnr) or connection.session_id ~= id then return end

    vim.ui.input({ prompt = "Codex session name: ", default = session.name or "" }, function(input)
      local name = input and vim.trim(input)
      if not name or name == "" then return end
      if not vim.api.nvim_buf_is_valid(chat.bufnr) or connection.session_id ~= id then
        return notify("chat session changed; rename cancelled")
      end
      manager.rename(id, name, function(_, rename_err)
        if rename_err then return notify("failed to rename session: " .. util.error_message(rename_err)) end
        if vim.api.nvim_buf_is_valid(chat.bufnr) and connection.session_id == id then
          chat:set_title(name)
          vim.b[chat.bufnr].codecompanion_tab_title = name
          vim.cmd("redrawstatus")
        end
        notify("session renamed", vim.log.levels.INFO)
      end)
    end)
  end)
end

function Extension.setup(opts)
  opts = opts or {}
  local chat = require("codecompanion.config").interactions.chat
  local keymaps = chat.keymaps
  keymaps.codex_sessions = {
    modes = { n = opts.keymap or "gC" },
    description = "Codex Sessions",
    callback = open_manager,
  }
  keymaps.codex_limits = {
    modes = { n = "gL" },
    description = "Codex limits",
    callback = function() require("codex_sessions").limits() end,
  }
  chat.slash_commands.delete = {
    description = "Permanently delete this Codex session",
    callback = Extension.delete_current,
  }
  chat.slash_commands.fork = {
    description = "Fork this Codex session into a new chat",
    callback = Extension.fork_current,
  }
  chat.slash_commands.rename = {
    description = "Rename the current session",
    enabled = function(context)
      local adapter = context.adapter
      return adapter and (adapter.type == "http" or adapter.name == "codex") or false
    end,
    callback = Extension.rename_current,
    opts = { contains_code = false },
  }
end

Extension.exports = {
  open = open_manager,
  refresh = function() require("codex_sessions").refresh() end,
  limits = function() require("codex_sessions").limits() end,
}

return Extension
