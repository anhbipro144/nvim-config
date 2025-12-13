return {
  -- {
  --   "JoosepAlviste/nvim-ts-context-commentstring",
  --   config = function()
  --     require('ts_context_commentstring').setup()
  --   end,
  -- },
  "folke/ts-comments.nvim",
  config = function()
    require("ts-comments").setup({
      lang = {
        tsx = {
          "// %s",                      -- default when no specific node matches
          "/* %s */",                   -- extra uncomment pattern; not used for adding
          tsx_attribute = "// %s",      -- <Comp {/* key="v" */} />
          tsx_element   = "{/* %s */}", -- {/* <Comp /> */}
          tsx_fragment  = "{/* %s */}", -- {/* <>...</> */}
        },
        javascript = {
          "// %s",
          "/* %s */",
          jsx_attribute = "{/* %s */}",
          jsx_element   = "{/* %s */}",
          jsx_fragment  = "{/* %s */}",
        },
      },
    })
  end,
  event = "VeryLazy",
  enabled = vim.fn.has("nvim-0.10.0") == 1,


}
