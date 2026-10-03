local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local util = require("codex_sessions.util")

local current

local function selected()
  local entry = action_state.get_selected_entry()
  return entry and entry.value
end

function M.close()
  if current and current.prompt_bufnr then
    local status = require("telescope.state").get_status(current.prompt_bufnr)
    if status.picker == current then actions.close(current.prompt_bufnr) end
  end
  current = nil
end

function M.show(rows, handlers)
  M.close()
  current = pickers.new({}, {
    prompt_title = handlers.title,
    initial_mode = "normal",
    finder = finders.new_table({
      results = rows,
      entry_maker = function(session)
        return {
          value = session,
          ordinal = table.concat({ session.name or "", session.preview or "", session.cwd or "", session.id or "" }, " "):gsub("%s+", " "),
          display = util.format_session(session),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local bind = function(key, callback)
        map("n", key, function()
          local session = selected()
          actions.close(prompt_bufnr)
          if session then vim.schedule(function() callback(session) end) end
        end)
      end
      if handlers.open_session then
        bind("<CR>", handlers.open_session)
      else
        map("n", "<CR>", function()
          local session = selected()
          if session then handlers.details(session) end
        end)
      end
      bind("r", handlers.rename)
      bind("f", handlers.fork)
      bind("a", handlers.archive)
      bind("d", handlers.delete)
      map("n", "D", function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local entries = picker:get_multi_selection()
        if #entries == 0 then return end
        local selected_rows = vim.tbl_map(function(entry) return entry.value end, entries)
        actions.close(prompt_bufnr)
        vim.schedule(function() handlers.bulk_delete(selected_rows) end)
      end)
      bind("y", handlers.copy_id)
      map("n", "R", function() actions.close(prompt_bufnr); vim.schedule(handlers.refresh) end)
      map("n", "A", function() actions.close(prompt_bufnr); vim.schedule(handlers.toggle_archived) end)
      map("n", "g", function() actions.close(prompt_bufnr); vim.schedule(handlers.toggle_cwd) end)
      map("n", "q", function() actions.close(prompt_bufnr) end)
      return true
    end,
  })
  current:find()
end

return M
