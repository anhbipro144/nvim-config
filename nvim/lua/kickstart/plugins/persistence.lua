return {
  -- 'rmagatti/auto-session',
  -- lazy = false,
  -- config = function()
  --   require("auto-session").setup {
  --     suppressed_dirs = { "~/", "~/Downloads", "/" },
  --   }
  -- end,
  --
  -- {
  --   "olimorris/persisted.nvim",
  --   lazy = false, -- make sure the plugin is always loaded at startup
  --   config = function()
  --     require("persisted").setup({
  --       autoload = true,
  --       pre_save = function()
  --         vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' })
  --       end
  --     })
  --   end
  --
  -- }
  --
  --
  -- Lua
  {
    "folke/persistence.nvim",
    event = "VimEnter", -- this will only start session saving when an actual file was opened
    config = function()
      require 'persistence'.setup {
        options = { --[[<other options>,]] 'globals' },
        pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end,

      }

      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
    end
  }
}
