return {
  "Goose97/timber.nvim",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    local timber = require("timber")

    timber.setup({
      keymaps = {
        insert_log_below                  = "<leader>ll",
        insert_plain_log_below            = "<leader>lj",
        add_log_targets_to_batch          = "<leader>la",
        insert_batch_log                  = "<leader>lb",
      },
    })
  end
}
