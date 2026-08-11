local utils = require("codecompanion.utils")

---@class CodeCompanion.SlashCommand.Resume: CodeCompanion.SlashCommand
local SlashCommand = {}
local session_paths

---@param args CodeCompanion.SlashCommand
function SlashCommand.new(args)
  return setmetatable({
    Chat = args.Chat,
    config = args.config,
    context = args.context,
  }, { __index = SlashCommand })
end

---@param chat CodeCompanion.Chat
---@return boolean,string
function SlashCommand.enabled(chat)
  if not chat.acp_connection then
    return false, "The resume slash command requires an ACP connection"
  end

  if not chat.acp_connection:can_list_sessions() then
    return false, "This agent does not support listing sessions"
  end

  if not chat.acp_connection:can_load_session() then
    return false, "This agent does not support loading sessions"
  end

  return true, ""
end

---@param value string
---@param max_chars integer
---@return string
local function truncate(value, max_chars)
  if vim.fn.strchars(value) <= max_chars then
    return value
  end

  return vim.fn.strcharpart(value, 0, max_chars - 1) .. "…"
end

---@return table<string, string>
local function codex_session_paths()
  if session_paths then
    return session_paths
  end

  session_paths = {}
  local root = vim.fn.expand("~/.codex/sessions")
  for _, path in ipairs(vim.fn.globpath(root, "**/*.jsonl", false, true)) do
    local session_id = path:match("([%x]+%-%x+%-%x+%-%x+%-%x+)%.jsonl$")
    if session_id then
      session_paths[session_id] = path
    end
  end

  return session_paths
end

---@param text string
---@return boolean
local function is_injected_context(text)
  return text:match("^# AGENTS%.md instructions")
      or text:match("^<environment_context>")
      or text:match("^<recommended_plugins>")
      or text:match("^<attachment ")
      or text:match("^Sharing the following file as context:")
      or text:match("^Sharing `[^`]+`:")
      or text:match("^Diagnostics for ")
end

---@param session_id string
---@return string|nil
local function first_prompt(session_id)
  local path = codex_session_paths()[session_id]
  if not path then
    return nil
  end

  local file = io.open(path, "r")
  if not file then
    return nil
  end

  for line in file:lines() do
    local ok, entry = pcall(vim.json.decode, line)
    local message = ok and entry.payload
    if message and message.type == "message" and message.role == "user" then
      for _, content in ipairs(message.content or {}) do
        if content.type == "input_text" and type(content.text) == "string" then
          local text = vim.trim(content.text)
          if text ~= "" and not is_injected_context(text) then
            file:close()
            return text:gsub("%s+", " ")
          end
        end
      end
    end
  end

  file:close()
  return nil
end

---@param session table SessionInfo
---@return string
local function format_session(session)
  local timestamp = session.updatedAt and utils.timestamp_from_iso(session.updatedAt)
  local updated = timestamp and os.date("%Y-%m-%d %H:%M", timestamp) or "unknown time"
  local id = session.sessionId or "unknown"
  local prompt = first_prompt(id)
  local label = truncate(prompt or session.title or id, 72)

  return string.format("%s  %s  [%s]", label, updated, id:sub(-12))
end

function SlashCommand:execute()
  local Chat = self.Chat

  if Chat.cycle > 1 then
    return utils.notify("The /resume command must be called before submitting any messages", vim.log.levels.WARN)
  end

  if not Chat.acp_connection then
    return utils.notify("No ACP connection available", vim.log.levels.WARN)
  end

  local sessions = Chat.acp_connection:session_list({
    max_sessions = (self.config.opts and self.config.opts.max_sessions) or 500,
  })

  if #sessions == 0 then
    return utils.notify("No previous sessions found", vim.log.levels.INFO)
  end

  local choices = {}
  local session_map = {}
  for i, session in ipairs(sessions) do
    table.insert(choices, format_session(session))
    session_map[i] = session
  end

  vim.ui.select(choices, {
    prompt = "Resume Session",
    kind = "codecompanion.nvim",
  }, function(_, idx)
    if not idx then
      return
    end

    local selected = session_map[idx]
    local updates = {}
    local ok = Chat.acp_connection:load_session(selected.sessionId, {
      on_session_update = function(update)
        table.insert(updates, update)
      end,
    })

    if ok then
      local acp_commands = require("codecompanion.interactions.chat.acp.commands")
      acp_commands.link_buffer_to_session(Chat.bufnr, Chat.acp_connection.session_id)
      require("codecompanion.interactions.chat.acp.render").restore_session(Chat, updates)

      if selected.title then
        Chat:set_title(selected.title)
      end

      utils.fire("ACPChatRestored", {
        bufnr = Chat.bufnr,
        id = Chat.id,
        session_id = Chat.acp_connection.session_id,
        title = Chat.title,
      })

      utils.notify("Resumed session: " .. (selected.title or selected.sessionId), vim.log.levels.INFO)
    else
      utils.notify("Failed to load session", vim.log.levels.ERROR)
    end
  end)
end

return SlashCommand
