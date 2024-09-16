-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'

    require('nvim-autopairs').setup {}
    -- If you want to automatically add `(` after selecting a function or method
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
