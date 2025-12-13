return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>cs", "<cmd>CodeSnap<cr>",      mode = "x", desc = "Save selected code snapshot into clipboard" },
    { "<leader>ci", "<cmd>CodeSnapASCII<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
    { "<leader>cS", "<cmd>CodeSnapSave<cr>",  mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
  },
  opts = {
    save_path = "~/Pictures",
    has_breadcrumbs = true,
    bg_theme = "bamboo",
    mac_window_bar = false,
    watermark = "" ,
    bg_x_padding = 80,
    bg_y_padding = 50,
  },
}
