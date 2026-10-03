local config = require("codex_sessions.config")
local Client = require("codex_sessions.client")
local Sessions = require("codex_sessions.sessions")
local UI = require("codex_sessions.ui")
local Limits = require("codex_sessions.limits")
local util = require("codex_sessions.util")

local M = { version = config.defaults.version }
local limits_win

local function show_limits(message)
  if limits_win and vim.api.nvim_win_is_valid(limits_win) then
    vim.api.nvim_win_close(limits_win, true)
  end
  local lines = vim.split(message, "\n", { plain = true })
  local width = 0
  for _, line in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(line)) end
  width = math.min(math.max(width, 32), math.max(1, vim.o.columns - 4))
  local height = math.min(#lines, math.max(1, vim.o.lines - 4))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  limits_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.max(0, math.floor((vim.o.lines - height) / 2)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Codex Limits ",
    title_pos = "center",
  })
  local function close()
    if vim.api.nvim_win_is_valid(limits_win) then vim.api.nvim_win_close(limits_win, true) end
  end
  for _, key in ipairs({ "q", "<Esc>", "<CR>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, nowait = true, silent = true })
  end
end

local function ensure_setup()
  if not M._client then M.setup() end
end

function M.setup(opts)
  local values = config.setup(opts)
  M._client = Client.new({
    command = values.codex.command,
    version = values.version,
    debug = values.debug,
  })
  M._sessions = Sessions.new(M._client)
  UI.setup({ sessions = M._sessions, config = values })
  return M
end

function M.open(opts)
  ensure_setup()
  UI.open(opts)
end

function M.refresh()
  ensure_setup()
  UI.refresh()
end

function M.limits()
  ensure_setup()
  Limits.read(M._client, function(rows, err)
    if err then return util.notify("failed to check limits: " .. util.error_message(err), vim.log.levels.ERROR) end
    local message = Limits.format(rows)
    if not message then return util.notify("no ChatGPT Codex limits available; check Codex sign-in", vim.log.levels.WARN) end
    show_limits(message)
  end)
end

function M.get(id, callback)
  ensure_setup()
  M._sessions:get(id, callback)
end

function M.rename(id, name, callback)
  ensure_setup()
  M._sessions:rename(id, name, callback)
end

function M.fork(id, opts, callback)
  ensure_setup()
  M._sessions:fork(id, opts, callback)
end

function M.delete(id, callback)
  ensure_setup()
  M._sessions:delete(id, callback)
end

function M.shutdown(callback)
  if M._client then
    M._client:stop(callback)
  elseif callback then
    callback()
  end
end

return M
