return {
  "stevearc/dressing.nvim",
  lazy = false, -- initialize at startup so ui overrides are global
  opts = {
    input = {
      enabled = true,
      default_prompt = "❯ ",
      border = "rounded",
      start_in_insert = true,
      win_options = {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      },
    },
    select = {
      enabled = true,
      backend = { "telescope", "fzf_lua", "builtin" },
      trim_prompt = true,
    },
  },
}
