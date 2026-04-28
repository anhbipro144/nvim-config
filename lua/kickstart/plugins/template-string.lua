return {
  "axelvc/template-string.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("template-string").setup({
      filetypes = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
      },
      jsx_brackets = true,
      remove_template_string = true,
    })
  end,
}
