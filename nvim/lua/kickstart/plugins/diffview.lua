return {
  "sindrets/diffview.nvim",
  config = function()
    local diffview = require("diffview")
    local actions = require("diffview.actions")

    -- local actions = require("diffview.actions")
    diffview.setup({
      file_panel = {
        win_config = { -- See |diffview-config-win_config|
          position = "right",
          width = 35,
          win_opts = {},
        },
      },
      view = {
        merge_tool = {
          layout = "diff3_mixed"
        },
      },
      keymaps = {
        view = {
          ["q"] = actions.close,
        },
        file_panel = {
          ["q"] = actions.close,

        }

      },
    })
  end
}
