return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
  config = function()
    local tsj = require('treesj')

    tsj.setup({
      use_default_keymaps = false,
      max_join_length = 500,
    })

    -- For default preset
    vim.keymap.set('n', '<c-;>', function ()
      tsj.toggle()
    end)

    vim.keymap.set('n', '<leader>M', function()
      tsj.toggle({ split = { recursive = true } })
    end)
  end,
}
