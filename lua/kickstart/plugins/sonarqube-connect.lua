return {
  "alnav3/sonarlint.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require('sonarlint').setup({
      server = {
        cmd = {
          'sonarlint-language-server',
          '-stdio',
          '-analyzers',
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
          vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
        },

        settings = {
          ["sonarlint.connectedMode.connections.sonarcloud"] = {
            {
              organizationKey = "ocean-network-express",
              token = os.getenv("SONARQUBE"), -- don't hardcode tokens in config 🙂
              -- connectionId = "optional-if-you-have-multiple"
              -- disableNotifications = true,
            },
          },

          ["sonarlint.connectedMode.project"] = {
            projectKey = "ocean-network-express",
            -- connectionId = "only if you set multiple connections above"
          },
        },
      },
      filetypes = {
        "javascript", "javascriptreact",
        "typescript", "typescriptreact",
        "python",
        "java",
      },

    })
  end,
}
