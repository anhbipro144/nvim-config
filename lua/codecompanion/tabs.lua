local M = {}

local chat_filetype = "codecompanion"
local chat_marker = "codecompanion_tab_chat"
local title_key = "codecompanion_tab_title"
local max_title_length = 35

local function is_valid_buffer(bufnr)
  return type(bufnr) == "number" and vim.api.nvim_buf_is_valid(bufnr)
end

function M.is_chat_buffer(bufnr)
  if not is_valid_buffer(bufnr) then
    return false
  end

  return vim.b[bufnr][chat_marker] == true or vim.bo[bufnr].filetype == chat_filetype
end

local function chat_buffers()
  local buffers = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_chat_buffer(bufnr) then
      table.insert(buffers, bufnr)
    end
  end

  table.sort(buffers)
  return buffers
end

local function next_default_title(bufnr)
  local used_numbers = {}
  local chat_count = 0

  for _, candidate in ipairs(chat_buffers()) do
    if candidate ~= bufnr and M.is_chat_buffer(candidate) then
      chat_count = chat_count + 1

      local title = vim.b[candidate][title_key]
      local number = type(title) == "string" and title:match("^CC (%d+)$")
      if number then
        used_numbers[tonumber(number)] = true
      end
    end
  end

  local number = chat_count + 1
  while used_numbers[number] do
    number = number + 1
  end

  return string.format("CC %d", number)
end

local function assign_default_title(bufnr)
  if not M.is_chat_buffer(bufnr) then
    return
  end

  local title = vim.b[bufnr][title_key]
  if type(title) ~= "string" or title == "" then
    vim.b[bufnr][title_key] = next_default_title(bufnr)
  end
end

local function redraw()
  vim.cmd("redrawstatus")
end

local function shortened_title(bufnr)
  local title = vim.b[bufnr][title_key]
  if type(title) ~= "string" or title == "" then
    title = "CodeCompanion"
  end

  if vim.fn.strchars(title) > max_title_length then
    title = vim.fn.strcharpart(title, 0, max_title_length - 1) .. "…"
  end

  local escaped = title:gsub("%%", "%%%%")
  return escaped
end

function M.open_chat(bufnr)
  if not M.is_chat_buffer(bufnr) then
    return
  end

  local codecompanion = require("codecompanion")
  local current = codecompanion.buf_get_chat(0)
  if current and current.bufnr ~= bufnr and current.ui and current.ui:is_visible() then
    current.ui:hide()
  end

  codecompanion.restore(bufnr)
end

function M.click_chat(bufnr, _, button)
  if button == "l" then
    M.open_chat(bufnr)
  end
end

function M.render_winbar()
  local winid = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
  local current = vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid)
    or vim.api.nvim_get_current_buf()
  local segments = { "%#TabLineFill#" }

  for _, bufnr in ipairs(chat_buffers()) do
    local highlight = bufnr == current and "TabLineSel" or "TabLine"
    table.insert(segments, string.format("%%#%s#%%%d@v:lua.CodeCompanionTabsClick@ %s %%X", highlight, bufnr, shortened_title(bufnr)))
    table.insert(segments, "%#TabLineFill# │ ")
  end

  if #segments > 1 then
    segments[#segments] = "%#TabLineFill#"
  end

  return table.concat(segments)
end

local function setup_winbar(bufnr)
  local winid = vim.fn.bufwinid(bufnr)
  if winid ~= -1 and vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].winbar = "%!v:lua.CodeCompanionTabsWinbar()"
  end
end

function M.rename_current_chat()
  local bufnr = vim.api.nvim_get_current_buf()
  if not M.is_chat_buffer(bufnr) then
    vim.notify("Current buffer is not a CodeCompanion chat", vim.log.levels.WARN)
    return
  end

  assign_default_title(bufnr)
  vim.ui.input({
    prompt = "Chat name: ",
    default = vim.b[bufnr][title_key],
  }, function(name)
    if not name or vim.trim(name) == "" or not is_valid_buffer(bufnr) then
      return
    end

    vim.b[bufnr][title_key] = vim.trim(name)
    redraw()
  end)
end

local function setup_keymap()
  for _, mapping in ipairs({ "<leader>cr", "<leader>cR", "<leader>cn" }) do
    local existing = vim.fn.maparg(mapping, "n", false, true)
    if next(existing) == nil or existing.desc == "Rename CodeCompanion chat" then
      vim.keymap.set("n", mapping, M.rename_current_chat, {
        desc = "Rename CodeCompanion chat",
      })
      return
    end
  end

  vim.notify("No free CodeCompanion chat rename mapping", vim.log.levels.WARN)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CodeCompanionTabs", { clear = true })

  _G.CodeCompanionTabsClick = M.click_chat
  _G.CodeCompanionTabsWinbar = M.render_winbar
  vim.o.showtabline = 1

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeCompanionChatCreated",
    callback = function(args)
      local bufnr = args.data and args.data.bufnr
      if not is_valid_buffer(bufnr) then
        return
      end

      vim.b[bufnr][chat_marker] = true
      assign_default_title(bufnr)
      redraw()
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeCompanionChatOpened",
    callback = function(args)
      local bufnr = args.data and args.data.bufnr
      if not is_valid_buffer(bufnr) then
        return
      end

      setup_winbar(bufnr)
      redraw()
    end,
  })

  for _, bufnr in ipairs(chat_buffers()) do
    if M.is_chat_buffer(bufnr) then
      vim.b[bufnr][chat_marker] = true
      assign_default_title(bufnr)
      setup_winbar(bufnr)
    end
  end

  setup_keymap()
  redraw()
end

return M
