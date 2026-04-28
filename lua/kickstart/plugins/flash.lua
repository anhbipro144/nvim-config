return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    { "ss", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
    { "S",  mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote(
          {
            search = { multi_window = true },
          }
        )
      end,
      desc = "Remote Flash"
    },
    {
      "<leader>R",
      mode = { 'n', "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search"
    },
  },

  config = function()
    require("flash").setup({
      search = { multi_window = true }, -- make it global, in case something overrides it
      modes = {
        treesitter_search = {
          remote_op = { restore = true }, -- ensure we snap back
        },
      },
      remote_op = {
        -- restore window views and cursor position
        -- after doing a remote operation
        restore = true,
        -- For `jump.pos = "range"`, this setting is ignored.
        -- `true`: always enter a new motion when doing a remote operation
        -- `false`: use the window's cursor position and jump target
        -- `nil`: act as `true` for remote windows, `false` for the current window
        motion = true,
      },
    })
  end
}
