return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  opts = {},
  config = function()
    local ts = require("typescript-tools")

    ts.setup({
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      on_attach = function(client, _)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      settings = {
        expose_as_code_action = "all",
        separate_diagnostic_server = false,

        tsserver_plugins = {
          "@styled/typescript-styled-plugin", -- TS v4.9+ recommendation
          -- "typescript-styled-plugin",       -- older TS (deprecated upstream)
        },

        -- tsserver_path = vim.fn.expand(
        --   "~/.local/share/tsserver-tools/node_modules/typescript/lib/tsserver.js"
        -- ),
      },
    })
  end,
}
