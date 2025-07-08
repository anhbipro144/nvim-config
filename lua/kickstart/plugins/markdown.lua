return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { "markdown", "codecompanion" },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  config = function()
    require('render-markdown').setup({
      sign = {
        enabled = false,
      },
      completions = { lsp = { enabled = true } },
      heading = {
        sign = false,
        icons = { '󰼏 ', '󰎨 ' },
        border = false,
        position = 'inline',
        border_virtual = false,

        backgrounds = {},
      },

      indent = {
        enabled = true,
        skip_heading = true,
      },

      bullet = {
        enabled = true,
        render_modes = false,
        icons = { '*', '○', '◆', '◇' },
        ordered_icons = function(ctx)
          local value = vim.trim(ctx.value)
          local index = tonumber(value:sub(1, #value - 1))
          return string.format('%d.', index > 1 and index or ctx.index)
        end,
        left_pad = 0,
        right_pad = 0,
        highlight = 'RenderMarkdownBullet',
        scope_highlight = {},
      },
    })
  end
}
