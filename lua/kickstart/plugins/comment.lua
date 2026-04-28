return {
  "folke/ts-comments.nvim",
  opts = {
    lang = {
      tsx = {
        "// %s",
        "/* %s */",

        -- ✅ This is the key for your exact case:
        jsx_opening_element      = "// %s",
        jsx_self_closing_element = "// %s",

        -- Keep these (defaults) for normal JSX children comments:
        jsx_attribute = "// %s",
        jsx_element   = "{/* %s */}",
        jsx_fragment  = "{/* %s */}",
      },
    },
  },
  event = "VeryLazy",
  enabled = vim.fn.has("nvim-0.10.0") == 1,
}

