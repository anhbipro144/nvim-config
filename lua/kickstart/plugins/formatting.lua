return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre', "BufNewFile" },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>ff',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },

    config = function()
      require("conform").setup({
        notify_on_error = false,
        -- format_on_save = function(bufnr)
        --   local disable_filetypes = { c = true, cpp = true }
        --   local lsp_format_opt
        --   if disable_filetypes[vim.bo[bufnr].filetype] then
        --     lsp_format_opt = 'never'
        --   else
        --     lsp_format_opt = 'fallback'
        --   end
        --   return {
        --     timeout_ms = 500,
        --     lsp_format = lsp_format_opt,
        --   }
        -- end,
        formatters_by_ft = {
          lua             = { 'stylua' },
          javascript      = { "prettierd", "prettier", stop_after_first = true },
          typescript      = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          cpp             = { "clang-format", stop_after_first = true },
          tsx             = { "prettierd", "prettier", stop_after_first = true },
          css             = { "prettier" },
          html            = { "prettier" },
          yaml            = { "prettier", stop_after_first = true },
          yml             = { "prettier", stop_after_first = true },
          json            = { "prettier", stop_after_first = true },
          nix             = { "nixfmt", stop_after_first = true },
        },

      })
    end
  },

}
