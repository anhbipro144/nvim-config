return {
  "NeogitOrg/neogit",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    -- "nvim-telescope/telescope.nvim",
  },
  keys = {
    { '<leader>gg', '<cmd>Neogit<CR>', mode = 'n', desc = 'Open Neogit' }
  },
  cmd = "Neogit",
  config = function()
    local neogit = require("neogit")
    -- local telescope_config = require("telescope")

    neogit.setup({
      telescope_sorter = nil,
      graph_style = "kitty",
      integrations = {
        diffview = true,
        telescope = nil
      },

      mappings = {
        finder = {
          ["<cr>"] = "Select",
          ["<c-j>"] = "Next",
          ["<c-k>"] = "Previous",
        },
      }
    })
  end,
}
