return {
  'axkirillov/hbac.nvim',
  config = function()
    require("hbac").setup({
      autoclose     = true,
      threshold     = 6,
      close_command = function(bufnr)
        vim.api.nvim_buf_delete(bufnr, {})
      end,
    })
  end,
}
