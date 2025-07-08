local M = {
  processing = false,
  spinner_index = 1,
  namespace_id = nil,
  timer = nil,
  spinner_symbols = {
    "⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏",
  },
  filetype = "codecompanion",
}

function M:get_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == self.filetype then
      return buf
    end
  end
end

function M:update_spinner()
  if not self.processing then return self:stop_spinner() end
  self.spinner_index = (self.spinner_index % #self.spinner_symbols) + 1
  local buf = self:get_buf(); if not buf then return end
  vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
  local last = vim.api.nvim_buf_line_count(buf) - 1
  vim.api.nvim_buf_set_extmark(buf, self.namespace_id, last, 0, {
    virt_lines = { { { self.spinner_symbols[self.spinner_index] .. " Processing...", "Comment" } } },
    virt_lines_above = false,
  })
end

function M:start_spinner()
  if self.timer then self.timer:stop(); self.timer:close() end
  self.processing = true; self.spinner_index = 0
  self.namespace_id = self.namespace_id or vim.api.nvim_create_namespace("CodeCompanionSpinner")
  self.timer = vim.loop.new_timer()
  self.timer:start(0, 100, vim.schedule_wrap(function() M:update_spinner() end))
end

function M:stop_spinner()
  self.processing = false
  if self.timer then self.timer:stop(); self.timer:close(); self.timer = nil end
  local buf = self:get_buf(); if not buf then return end
  vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
end

function M:init()
  vim.api.nvim_create_augroup("CodeCompanionSpinner", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestStarted",
    callback = function() M:start_spinner() end,
    group = "CodeCompanionSpinner",
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestFinished",
    callback = function() M:stop_spinner() end,
    group = "CodeCompanionSpinner",
  })
end

return M
