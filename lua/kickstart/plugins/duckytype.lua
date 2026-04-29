return {
  "kwakzalver/duckytype.nvim",
  config = function()
    local ducky = require('duckytype')

    ducky.setup({
      window_config = {
        width = math.floor(vim.o.columns * 0.75),
        height = math.floor(vim.o.lines * 0.35),
        border = "rounded",
      },
    })

    vim.keymap.set('n', "<leader>dt", function()
      ducky.Start("english_common")
    end, { noremap = true })
  end
}
