return {
  "kopecmaciej/vi-sql.nvim",
  config = function()
    require("vi-sql").setup({
      -- `<leader>sq` opens vi-sql; the same shortcut hides it from inside vi-sql.
      hide_key = "<leader>sq",
    })
  end,
  cmd = { "ViSQL", "ViSQLJump" },
  keys = {
    { "<leader>sq", "<cmd>ViSQL<cr>", desc = "Open vi-sql" },
    -- { "<leader>vj", ":ViSQLJump ", desc = "vi-sql: jump to table", silent = false },
  },
}
