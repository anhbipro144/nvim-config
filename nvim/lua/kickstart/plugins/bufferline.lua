return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local bufferline = require("bufferline")
    bufferline.setup({})


    -- Move buffer
    vim.keymap.set('n', '<S-j>', ':BufferLineMovePrev<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<S-k>', ':BufferLineMoveNext<CR>', { noremap = true, silent = true })


    -- Navigate buffers
    vim.keymap.set('n', '<S-h>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<S-l>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
  end
}
