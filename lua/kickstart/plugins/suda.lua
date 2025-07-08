return {
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaRead", "SudaWrite" },
    -- Optional: smart edit mode
    config = function()
      vim.g.suda_smart_edit = 1
    end,
  },
}
