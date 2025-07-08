return {
  {
    -- use a local directory for development
    dir = "/home/neo/personal/learn/codecompanion-history.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim", -- for telescope picker
    },
    config = function()
      require("codecompanion").setup({
        keymap = "gh",
        save_chat_keymap = "sc",
        auto_save = true,
        expiration_days = 3,
        picker = "telescope",
        auto_generate_title = true,
        title_generation_opts = {
          adapter = nil,                   -- "copilot"
          model = nil,                     -- "gpt-4o"
          refresh_every_n_prompts = 3,     -- e.g., 3 to refresh after every 3rd user prompt
          max_refreshes = 3,
        },
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        enable_logging = false,
        chat_filter = nil,     -- function(chat_data) return boolean end
        picker_keymaps = {
          rename = {
            n = "r",
            i = "<C-r>",
          },
          delete = {
            n = "d",
            i = "<C-d>",
          },
        },
      })
    end,
  },
}
