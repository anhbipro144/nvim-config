return {
  'mistweaverco/kulala.nvim',
  config = function()
    local kulala = require('kulala')

    kulala.setup({
    })


    vim.keymap.set('n', '<leader>rr', function()
      kulala.run()
    end, { noremap = true, silent = true })

    vim.keymap.set('n', '<leader>rt', function()
      kulala.toggle_view()
    end, { noremap = true, silent = true })

    vim.keymap.set('n', '<leader>rx', function()
      kulala.close()
    end, { noremap = true, silent = true })

    vim.keymap.set('n', '<leader>rs', function()
      kulala.search()
    end, { noremap = true, silent = true })
  end
}
