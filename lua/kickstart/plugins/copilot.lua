return {
  "github/copilot.vim",
  config = function()
    vim.cmd("Copilot enable")
    vim.g.copilot_filetypes = { ['*'] = false }
    vim.keymap.set('i', '<S-x>', 'copilot#Suggest()', { silent = true, expr = true, noremap = true })
  end,
}
