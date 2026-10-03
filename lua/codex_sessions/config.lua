local M = {}

M.defaults = {
  version = "0.1.0",
  codex = { command = "codex" },
  picker = {
    backend = "telescope",
    current_cwd_only = true,
  },
  confirm_delete = true,
  debug = false,
}

M.values = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.values
end

return M
