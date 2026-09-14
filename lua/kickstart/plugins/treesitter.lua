return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'

      treesitter.setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }
      treesitter.install { 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'python', 'typescript', 'javascript', 'cpp' }

      local group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
        end,
      })
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et
