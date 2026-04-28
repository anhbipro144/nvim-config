return {
  -- "anuvyklack/windows.nvim",
  -- dependencies = {
  --   "anuvyklack/middleclass",
  --   "anuvyklack/animation.nvim"
  -- },
  -- config = function()
  --   vim.o.winwidth = 10
  --   vim.o.winminwidth = 10
  --   vim.o.equalalways = false
  --   require('windows').setup({
  --     animation = {
  --       duration = 150,
  --       fps = 60,
  --     }
  --
  --
  --   })
  --
  --   local function cmd(command)
  --     return table.concat({ '<Cmd>', command, '<CR>' })
  --   end
  --
  --   vim.keymap.set('n', '<S-A-d>', cmd 'WindowsMaximize')
  --   vim.keymap.set('n', '<C-w>_', cmd 'WindowsMaximizeVertically')
  --   vim.keymap.set('n', '<C-w>|', cmd 'WindowsMaximizeHorizontally')
  --   vim.keymap.set('n', '<C-w>=', cmd 'WindowsEqualize')
  -- end
  --
  'nvim-focus/focus.nvim',
  version = '*',
  keys = {
    { "<C-h>", function() require("focus").split_command("h") end, desc = "Focus left" },
    { "<C-j>", function() require("focus").split_command("j") end, desc = "Focus down" },
    { "<C-k>", function() require("focus").split_command("k") end, desc = "Focus up" },
    { "<C-l>", function() require("focus").split_command("l") end, desc = "Focus right" },
  },
  config = function()
    local focus = require("focus")
    focus.setup()
  end
}
