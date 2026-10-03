if vim.g.loaded_codex_sessions then return end
vim.g.loaded_codex_sessions = true

vim.api.nvim_create_user_command("CodexSessions", function()
  require("codex_sessions").open()
end, { desc = "Manage local Codex sessions" })

vim.keymap.set("n", "<leader>cs", "<Cmd>CodexSessions<CR>", { desc = "Codex sessions" })

vim.api.nvim_create_user_command("CodexSessionsRefresh", function()
  require("codex_sessions").refresh()
end, { desc = "Refresh Codex sessions" })

vim.api.nvim_create_user_command("CodexLimits", function()
  require("codex_sessions").limits()
end, { desc = "Show ChatGPT Codex rate limits" })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("codex_sessions", { clear = true }),
  callback = function() require("codex_sessions").shutdown() end,
})
