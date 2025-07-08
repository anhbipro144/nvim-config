return {
  'romgrk/barbar.nvim',
  dependencies = {
    'famiu/bufdelete.nvim'

  },
  config = function()
    require("barbar").setup({
      animation = false,
      icons = {
        filetype = {
          custom_colors = true
        },
        button = '',
        separator = { right = '', left = '▎' },
      }
    })


    vim.opt.showtabline = 0

    -- Buffer management
    -- vim.keymap.set('n', '<S-k>', ':BufferMoveNext<CR>', { noremap = true, silent = true })     -- Move buffer 1 step to the right
    -- vim.keymap.set('n', '<S-j>', ':BufferMovePrevious<CR>', { noremap = true, silent = true }) --  Move buffer 1 step to the left


    vim.keymap.set('n', '<S-B><S-D>', ':BufferClose<CR>', { noremap = true, silent = true })   --  Close current buffer
    vim.keymap.set('n', '<S-B><S-R>', ':BufferRestore<CR>', { noremap = true, silent = true }) --  Restore closed buffer


    -- vim.keymap.set('n', '<S-l>', ':BufferNext<CR>', { noremap = true, silent = true })     -- Go to to next buffer (on the right)
    -- vim.keymap.set('n', '<S-h>', ':BufferPrevious<CR>', { noremap = true, silent = true }) -- Go to the previous buffer (on the left)
  end,
  version = '^1.0.0',

}
