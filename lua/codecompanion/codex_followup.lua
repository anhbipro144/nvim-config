-- Codex ACP steering is a private codex-acp extension, not a CodeCompanion API.
local M = {}
local ns = vim.api.nvim_create_namespace("CodeCompanionCodexFollowup")
local pending = setmetatable({}, { __mode = "k" })
local attached = setmetatable({}, { __mode = "k" })

local function render(chat)
  if not vim.api.nvim_buf_is_valid(chat.bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(chat.bufnr, ns, 0, -1)
  local entries = pending[chat]
  if not entries or #entries == 0 then
    return
  end
  local lines = {}
  for _, entry in ipairs(entries) do
    local summary = entry.text:gsub("%s+", " ")
    summary = vim.fn.strcharpart(summary, 0, 90)
    lines[#lines + 1] = { { " ↳ Follow-up " .. entry.status .. ": " .. summary, "Comment" } }
  end
  vim.api.nvim_buf_set_extmark(chat.bufnr, ns, vim.api.nvim_buf_line_count(chat.bufnr) - 1, 0, {
    virt_lines = lines,
  })
end

local function forget(chat)
  pending[chat] = nil
  render(chat)
  chat:remove_callback("on_completed", forget)
  chat:remove_callback("on_closed", forget)
end

local function is_codex(chat)
  return chat and chat.adapter and chat.adapter.type == "acp" and chat.adapter.name == "codex"
end

function M.send(chat, text)
  if not is_codex(chat) then
    return vim.notify("Codex follow-up is only available in Codex ACP chats", vim.log.levels.WARN)
  end
  local connection = chat.acp_connection
  if not chat.current_request or not connection or not connection:is_connected() then
    return vim.notify("Codex follow-up needs an active Codex turn", vim.log.levels.WARN)
  end
  text = vim.trim(text or "")
  if text == "" then
    return
  end

  local entries = pending[chat]
  if not entries then
    entries = {}
    pending[chat] = entries
    chat:add_callback("on_completed", forget)
    chat:add_callback("on_closed", forget)
    if not attached[chat] then
      attached[chat] = vim.api.nvim_buf_attach(chat.bufnr, false, {
        on_lines = function()
          if pending[chat] then
            vim.schedule(function()
              if pending[chat] then render(chat) end
            end)
          end
        end,
        on_detach = function()
          pending[chat] = nil
          attached[chat] = nil
        end,
      })
    end
  end

  local entry = { text = text, status = "sending" }
  table.insert(entries, entry)
  render(chat)
  local session_id = connection.session_id
  require("codecompanion.utils.async").sync(function()
    local result = connection:send_rpc_request("_session/steering", {
      sessionId = session_id,
      prompt = { { type = "text", text = text } },
    })
    if pending[chat] ~= entries then return end
    if result and result.outcome == "injected" then
      entry.status = "accepted for this turn"
    elseif result and result.outcome == "startedNewTurn" then
      entry.status = "started a new turn"
      vim.notify("Codex follow-up arrived after the active turn ended", vim.log.levels.WARN)
    else
      for i, item in ipairs(entries) do
        if item == entry then table.remove(entries, i) break end
      end
      vim.notify("Codex follow-up failed; the message was not accepted", vim.log.levels.ERROR)
    end
    render(chat)
  end)()
end

function M.open(chat)
  if not is_codex(chat) or not chat.current_request or not chat.acp_connection then
    return vim.notify("Codex follow-up needs an active Codex ACP chat", vim.log.levels.WARN)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local width = math.max(1, math.min(100, vim.o.columns - 4))
  local height = math.max(1, math.min(12, vim.o.lines - 4))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    border = "rounded",
    style = "minimal",
    title = " Steer Codex ",
    footer = " <CR>/<C-s> send · q cancel ",
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  local function submit()
    local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
    if text == "" then return end
    if not chat.current_request or not chat.acp_connection or not chat.acp_connection:is_connected() then
      return vim.notify("Codex follow-up needs an active Codex turn", vim.log.levels.WARN)
    end
    close()
    M.send(chat, text)
  end
  vim.keymap.set("n", "<CR>", submit, { buffer = buf, desc = "Send Codex follow-up" })
  vim.keymap.set({ "n", "i" }, "<C-s>", submit, { buffer = buf, desc = "Send Codex follow-up" })
  vim.keymap.set("n", "q", close, { buffer = buf, desc = "Cancel Codex follow-up" })
  vim.cmd.startinsert()
end

return M
