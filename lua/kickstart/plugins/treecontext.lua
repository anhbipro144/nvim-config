return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    local select = require 'nvim-treesitter-textobjects.select'

    require('nvim-treesitter-textobjects').setup {
      select = {
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v',
          ['@function.outer'] = 'V',
          ['@class.outer'] = '<c-v>',
        },
        include_surrounding_whitespace = true,
      },
    }

    local keymaps = {
      af = { '@function.outer' },
      ['if'] = { '@function.inner' },
      aC = { '@class.outer' },
      iC = { '@class.inner', nil, 'Select inner part of a class region' },
      am = { '@call.outer' },
      im = { '@call.inner' },
      ac = { '@conditional.outer' },
      ic = { '@conditional.inner' },
      al = { '@loop.outer' },
      il = { '@loop.inner' },
      ad = { '@comment.outer' },
      id = { '@comment.inner' },
      ['as'] = { '@local.scope', 'locals', 'Select language scope' },
      ['a='] = { '@assignment.outer' },
      ['i='] = { '@assignment.inner' },
    }

    for keys, textobject in pairs(keymaps) do
      vim.keymap.set({ 'x', 'o' }, keys, function()
        select.select_textobject(textobject[1], textobject[2] or 'textobjects')
      end, { desc = textobject[3] })
    end
  end,
}
