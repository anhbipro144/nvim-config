local util = require("codex_sessions.util")
local M = {}

local state = {
  sessions = nil,
  config = nil,
  archived = false,
  current_cwd_only = true,
  rows = {},
  on_select = nil,
}

local function backend()
  if state.config.picker.backend ~= "telescope" then return nil end
  local ok, telescope = pcall(require, "codex_sessions.telescope")
  return ok and telescope or nil
end

local function close_picker()
  local telescope = backend()
  if telescope then telescope.close() end
end

local function run(action, callback)
  action(function(result, err)
    if err then
      util.notify(callback.error .. ": " .. util.error_message(err), vim.log.levels.ERROR)
    else
      util.notify(callback.success, vim.log.levels.INFO)
      callback.done(result)
    end
  end)
end

function M.setup(opts)
  state.sessions = opts.sessions
  state.config = opts.config
  state.current_cwd_only = state.config.picker.current_cwd_only
end

function M.confirm_delete(session, select, callback, confirm)
  if not confirm then return callback() end
  local prompt = string.format(
    'Delete Codex session "%s" (%s) permanently?',
    session.name or "(unnamed)",
    util.short_id(session.id)
  )
  select({ "Delete permanently", "Cancel" }, { prompt = prompt }, function(choice)
    if choice == "Delete permanently" then callback() end
  end)
end

function M.confirm_bulk_delete(sessions, select, callback)
  local choice = string.format("Delete %d permanently", #sessions)
  local lines = { string.format("Delete %d Codex sessions permanently?", #sessions) }
  for _, session in ipairs(sessions) do
    lines[#lines + 1] = string.format('"%s" (%s)', util.truncate(session.name or "(unnamed)", 80), session.id)
  end
  select({ choice, "Cancel" }, { prompt = table.concat(lines, "\n") }, function(selected)
    if selected == choice then callback() end
  end)
end

function M.refresh(select_id)
  close_picker()
  state.sessions:list({
    archived = state.archived,
    current_cwd_only = state.current_cwd_only,
  }, function(rows, err)
    if err then
      return util.notify("failed to list sessions: " .. util.error_message(err), vim.log.levels.ERROR)
    end
    state.rows = rows or {}
    M._render(select_id)
  end)
end

function M._render(select_id)
  local title = string.format(
    "Codex Sessions [%s|%s]",
    state.archived and "archived" or "active",
    state.current_cwd_only and "cwd" or "all"
  )
  local telescope = backend()
  if telescope then
    telescope.show(state.rows, {
      title = title,
      details = M.details,
      open_session = state.on_select,
      rename = M.rename,
      fork = M.fork,
      archive = M.toggle_archive,
      delete = M.delete,
      bulk_delete = M.bulk_delete,
      copy_id = M.copy_id,
      refresh = M.refresh,
      toggle_archived = M.toggle_archived,
      toggle_cwd = M.toggle_cwd,
    })
    return
  end
  if #state.rows == 0 then return util.notify("no sessions found", vim.log.levels.INFO) end
  local choices = vim.tbl_map(function(session) return util.format_session(session) end, state.rows)
  vim.ui.select(choices, { prompt = title }, function(_, index)
    if index then
      if state.on_select then state.on_select(state.rows[index]) else M.actions(state.rows[index]) end
    end
  end)
end

function M.open(opts)
  if not state.sessions then return end
  state.on_select = opts and opts.on_select or nil
  M.refresh()
end

function M.actions(session)
  local choices = {
    "Rename",
    "Fork",
    session.archived and "Unarchive" or "Archive",
    "Delete",
    "Copy session ID",
    "Close",
  }
  M.details(session)
  vim.ui.select(choices, { prompt = "Codex session action" }, function(choice)
    if choice == "Rename" then M.rename(session)
    elseif choice == "Fork" then M.fork(session)
    elseif choice == "Archive" or choice == "Unarchive" then M.toggle_archive(session)
    elseif choice == "Delete" then M.delete(session)
    elseif choice == "Copy session ID" then M.copy_id(session)
    end
  end)
end

function M.details(session)
  vim.notify(util.session_details(session), vim.log.levels.INFO, { title = "Codex Sessions" })
end

function M.rename(session)
  vim.ui.input({ prompt = "Rename session: ", default = session.name or "" }, function(name)
    if not name or vim.trim(name) == "" then return end
    run(function(done) state.sessions:rename(session.id, vim.trim(name), done) end, {
      error = "failed to rename session",
      success = "session renamed",
      done = function() M.refresh(session.id) end,
    })
  end)
end

function M.fork(session)
  run(function(done) state.sessions:fork(session.id, { exclude_turns = true }, done) end, {
    error = "failed to fork session",
    success = "session forked",
    done = function(forked)
      if not forked or not forked.id then return M.refresh() end
      vim.ui.input({ prompt = "Name fork: " }, function(name)
        local finish = function() M.refresh(forked.id) end
        if not name or vim.trim(name) == "" then return finish() end
        run(function(done) state.sessions:rename(forked.id, vim.trim(name), done) end, {
          error = "failed to name fork",
          success = "fork named",
          done = finish,
        })
      end)
    end,
  })
end

function M.toggle_archive(session)
  local action = session.archived and state.sessions.unarchive or state.sessions.archive
  local message = session.archived and "session unarchived" or "session archived"
  run(function(done) action(state.sessions, session.id, done) end, {
    error = session.archived and "failed to unarchive session" or "failed to archive session",
    success = message,
    done = function() M.refresh() end,
  })
end

function M.delete(session)
  M.confirm_delete(session, vim.ui.select, function()
    run(function(done) state.sessions:delete(session.id, done) end, {
      error = "deletion rejected",
      success = "session deleted",
      done = function() M.refresh() end,
    })
  end, state.config.confirm_delete)
end

function M.bulk_delete(selected)
  local sessions, seen = {}, {}
  for _, session in ipairs(selected or {}) do
    if type(session.id) == "string" and session.id ~= "" and not seen[session.id] then
      seen[session.id] = true
      sessions[#sessions + 1] = session
    end
  end
  if #sessions == 0 then return end

  M.confirm_bulk_delete(sessions, vim.ui.select, function()
    local index, deleted, failures = 1, 0, {}
    local function next_delete()
      local session = sessions[index]
      if not session then
        util.notify(string.format("deleted %d of %d sessions", deleted, #sessions))
        for _, failure in ipairs(failures) do
          util.notify("deletion rejected for " .. failure.id .. ": " .. failure.error, vim.log.levels.ERROR)
        end
        return M.refresh()
      end
      index = index + 1
      state.sessions:delete(session.id, function(_, err)
        if err then
          failures[#failures + 1] = { id = session.id, error = util.error_message(err) }
        else
          deleted = deleted + 1
        end
        next_delete()
      end)
    end
    next_delete()
  end)
end

function M.copy_id(session)
  vim.fn.setreg("+", session.id)
  util.notify("copied session ID " .. session.id)
end

function M.toggle_archived()
  state.archived = not state.archived
  M.refresh()
end

function M.toggle_cwd()
  state.current_cwd_only = not state.current_cwd_only
  M.refresh()
end

return M
