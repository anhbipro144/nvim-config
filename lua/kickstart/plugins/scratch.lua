-- use lazy.nvim
return {
  "LintaoAmons/scratch.nvim",
  event = "VeryLazy",
  config = function()
    require("scratch").setup({
      file_picker = "telescope",                      -- "fzflua" | "telescope" | "snacks" | nil
      filetypes = { "lua", "js", "sh", "ts", "tsx" }, -- you can simply put filetype here
    })


    vim.keymap.set("n", "<leader>rs", "<cmd>Scratch<cr>")
    vim.keymap.set("n", "<leader>ro", "<cmd>ScratchOpen<cr>")
  end
}
