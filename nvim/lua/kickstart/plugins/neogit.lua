return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",

    --
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { '<leader>gs', '<cmd>Neogit<CR>', mode = 'n', desc = 'Open Neogit' }
  },
  cmd = "Neogit",
  config = function()
    local neogit = require("neogit")
    local diffview = require("diffview")
    local telescope_config = require("telescope")

    neogit.setup({
      telescope_sorter = function()
        return telescope_config.extensions.fzf.native_fzf_sorter()
      end,

      graph_style = "unicode",
      integrations = {
        diffview = true,
      },

      mappings = {
        finder = {
          ["<cr>"] = "Select",
          ["<c-j>"] = "Next",
          ["<c-k>"] = "Previous",
        },
        -- status = {
        --   ["d"] = "DiffviewOpen",
        -- },
      }


    })

    local actions = require("diffview.actions")
    diffview.setup({
      file_panel = {
        win_config = { -- See |diffview-config-win_config|
          position = "right",
          width = 35,
          win_opts = {},
        },
      },
      merge_tool = {
        default = {
          layout = "diff3_mixed"
        }
      },
    })
  end,
}
