return {
  "rmagatti/auto-session",
  lazy = false,
  keys = {
    { "<leader>wr", "<cmd>AutoSession search<CR>", desc = "Session search" },
    { "<leader>ws", "<cmd>AutoSession save<CR>",   desc = "Save session" },
    { "<leader>wa", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
  },
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    auto_save = true,                                       -- Enables/disables auto saving session on exit
    auto_restore = true,                                    -- Enables/disables auto restoring session on start
    -- Don’t create/restore sessions in these places
    suppressed_dirs = { "~/", "~/Downloads", "/tmp", "/" }, -- :contentReference[oaicite:2]{index=2}

    -- Avoid saving a “session” that’s just your dashboard
    bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" }, -- :contentReference[oaicite:3]{index=3}

    -- Big one for worktrees: when cwd changes, save old session + restore new one
    -- Note: it *clears buffers* on DirChangedPre to prevent “bleeding” between sessions. :contentReference[oaicite:4]{index=4}
    cwd_change_handling = true, -- :contentReference[oaicite:5]{index=5}

    -- Keep weird plugin windows from breaking session saves
    close_unsupported_windows = true,            -- :contentReference[oaicite:6]{index=6}
    close_filetypes_on_save = { "checkhealth" }, -- :contentReference[oaicite:7]{index=7}

    -- Session picker UI (Telescope/Snacks/fzf-lua/vim.ui.select auto-detected) :contentReference[oaicite:8]{index=8}
    session_lens = {
      load_on_setup = true, -- :contentReference[oaicite:9]{index=9}
      mappings = {
        delete_session = { "i", "<C-d>" },
        alternate_session = { "i", "<C-s>" },
        copy_session = { "i", "<C-y>" },
      }, -- :contentReference[oaicite:10]{index=10}
    },
  },
}
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
-- {
--   "folke/persistence.nvim",
--   event = "VimEnter", -- this will only start session saving when an actual file was opened
--   config = function()
--     require 'persistence'.setup {
--       options = { --[[<other options>,]] 'globals' },
--       pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end,
--     }
--
--     vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end)
--   end
-- }
-- }
