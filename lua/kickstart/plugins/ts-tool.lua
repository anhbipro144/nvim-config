return {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- ← here
  opts = {},
  init = function()
    vim.g.coq_settings = {
      auto_start = true,
    }
  end,
  config = function()
    local ts = require("typescript-tools")

    ts.setup({

      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      on_attach =
          function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
      settings = {
        expose_as_code_action = "all",
        separate_diagnostic_server = false,
      }
    }
    )
  end
}
