return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    insert_mode_after_paste = false,
    filetypes = {
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>v", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard", nowait = true },
  },
}
