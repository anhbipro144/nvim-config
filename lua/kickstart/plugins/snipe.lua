return {
  "leath-dub/snipe.nvim",
  dependencies = {
    'famiu/bufdelete.nvim'

  },
  keys = {
    { "\\", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" },
    -- {
    --   "<S-b><S-d>",
    --   function()
    --     require('bufdelete').bufdelete(0, true)
    --   end,
    --   desc = "Open Snipe buffer menu"
    -- }
  },
  opts = {
    ui = {
      position          = "center",
      preselect_current = false,
      open_win_override = {
        title = "Buffers",
        border = "rounded"
      },
      text_align        = "file-first",
    },
    navigate = {
      cancel_snipe = "q",
    }

  },
  lazy = false

}
