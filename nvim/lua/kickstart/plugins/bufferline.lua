return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({})
    vim.keymap.set('n', '<S-u>', ':BufferLineMovePrev<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<S-i>', ':BufferLineMoveNext<CR>', { noremap = true, silent = true })
  end
}
