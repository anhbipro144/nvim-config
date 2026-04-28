-- Filetype detection setup
vim.filetype.add({
  pattern = {
    ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
    ["compose%.ya?ml"] = "yaml.docker-compose",
  },
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
})


-- Conifg diagnostic
vim.diagnostic.config {
  signs = true,
  underline = true,
  virtual_text = true,
  virtual_lines = false,
  update_in_insert = true,
  float = {
    header = false,
    border = 'rounded',
    focusable = true,
  } }

vim.keymap.set('n', '<leader>dp', function()
  vim.diagnostic.open_float({ border = 'rounded' })
end, { noremap = true, silent = true })
