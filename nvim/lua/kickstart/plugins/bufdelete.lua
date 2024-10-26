return {
  "famiu/bufdelete.nvim",
  event = "VeryLazy",
  config = function()
    local opts = { noremap = true, silent = true }


    vim.keymap.set("n", "<S-B><S-D>", ":lua require('bufdelete').bufdelete(0, false)<cr>", opts)
  end


}
