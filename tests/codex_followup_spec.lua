local Followup = require("codecompanion.codex_followup")

local function fake_chat()
  local callbacks, sent = {}, {}
  local connection = {
    session_id = "test-session",
    outcome = "injected",
    is_connected = function() return true end,
    send_rpc_request = function(self, method, params)
      assert(#vim.api.nvim_buf_get_extmarks(self.bufnr, -1, 0, -1, {}) == 1)
      sent[#sent + 1] = { method = method, params = params }
      return self.outcome and { outcome = self.outcome } or nil
    end,
  }
  local chat = {
    adapter = { type = "acp", name = "codex" },
    acp_connection = connection,
    current_request = {},
    bufnr = vim.api.nvim_create_buf(false, true),
    add_callback = function(_, event, callback) callbacks[event] = callback end,
    remove_callback = function(_, event) callbacks[event] = nil end,
  }
  connection.bufnr = chat.bufnr
  return chat, sent, callbacks, connection
end

local chat, sent, callbacks, connection = fake_chat()
Followup.send(chat, "  fetch my jira tickets  ")
assert(#sent == 1)
assert(sent[1].method == "_session/steering")
assert(sent[1].params.sessionId == "test-session")
assert(sent[1].params.prompt[1].text == "fetch my jira tickets")
local marks = vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, { details = true })
assert(#marks == 1)
assert(marks[1][4].virt_lines[1][1][1]:find("accepted for this turn", 1, true))
Followup.send(chat, "and show priorities")
assert(#sent == 2 and sent[2].params.prompt[1].text == "and show priorities")
marks = vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, { details = true })
assert(#marks == 1 and #marks[1][4].virt_lines == 2)
vim.api.nvim_buf_set_lines(chat.bufnr, -1, -1, false, { "starting response" })
vim.wait(20)
assert(#vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, {}) == 1)
assert(type(callbacks.on_completed) == "function")
callbacks.on_completed(chat)
assert(callbacks.on_completed == nil)
assert(#vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, {}) == 0)

local editor_chat, editor_sent = fake_chat()
Followup.open(editor_chat)
local editor_buf = vim.api.nvim_get_current_buf()
assert(editor_buf ~= editor_chat.bufnr)
local long_text = string.rep("x", 10000)
vim.api.nvim_buf_set_lines(editor_buf, 0, -1, false, { long_text, "second line" })
local send_map = vim.fn.maparg("<CR>", "n", false, true)
assert(type(send_map.callback) == "function")
assert(type(vim.fn.maparg("<C-s>", "i", false, true).callback) == "function")
send_map.callback()
assert(#editor_sent == 1)
assert(editor_sent[1].params.prompt[1].text == long_text .. "\nsecond line")
assert(not vim.api.nvim_buf_is_valid(editor_buf))
Followup.open(editor_chat)
local cancel_buf = vim.api.nvim_get_current_buf()
local cancel_map = vim.fn.maparg("q", "n", false, true)
assert(type(cancel_map.callback) == "function")
cancel_map.callback()
assert(not vim.api.nvim_buf_is_valid(cancel_buf) and #editor_sent == 1)
vim.api.nvim_buf_delete(editor_chat.bufnr, { force = true })

local old_notify = vim.notify
local notice
vim.notify = function(message) notice = message end
connection.outcome = "startedNewTurn"
Followup.send(chat, "late but accepted")
assert(#sent == 3)
assert(notice:find("active turn ended", 1, true))
assert(#vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, {}) == 1)
callbacks.on_completed(chat)
assert(#vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, {}) == 0)
connection.outcome = nil
Followup.send(chat, "rejected")
assert(#sent == 4)
assert(notice:find("not accepted", 1, true))
assert(#vim.api.nvim_buf_get_extmarks(chat.bufnr, -1, 0, -1, {}) == 0)
chat.current_request = nil
Followup.send(chat, "too late")
assert(#sent == 4 and notice:find("active Codex turn", 1, true))
chat.current_request = {}
chat.adapter.name = "gemini_cli"
Followup.send(chat, "wrong agent")
assert(#sent == 4 and notice:find("only available", 1, true))
vim.notify = old_notify
vim.api.nvim_buf_delete(chat.bufnr, { force = true })

print("codex_followup tests: ok")
