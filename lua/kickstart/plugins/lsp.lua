return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      'williamboman/mason.nvim',
      cmd = { "Mason" },
      config = true,
    },
    "williamboman/mason-lspconfig.nvim",
    'hrsh7th/nvim-cmp',
    "hrsh7th/cmp-nvim-lsp",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    'nvim-lua/plenary.nvim',
    'nvimtools/none-ls.nvim',
  },
  config = function()
    local lsp_util = require("lspconfig.util")
    local telescope_builtin = require("telescope.builtin")
    -- local cmp_capabilites = require('blink.cmp').get_lsp_capabilities()

    local base_caps = vim.lsp.protocol.make_client_capabilities()
    local capabilities = require('cmp_nvim_lsp').default_capabilities(base_caps)


    local manual_servers = {
      clangd = {
        cmd          = {
          "clangd",
          "--background-index",
        },
        init_options = {
          fallbackFlags = { '-std=c++23' }
        },
        filetypes    = { "c", "cpp" }
      },


      neocmake = {
        cmd = { "neocmakelsp", "--stdio" },
        filetypes = { "cmake" },
        root_dir = function(fname)
          return lsp_util.find_git_ancestor(fname)
        end,
        single_file_support = true,
        init_options = {
          format = {
            enable = true
          },
          lint = {
            enable = true
          },
          scan_cmake_in_package = true
        }
      },
    }

    local servers = {
      ["docker-compose-language-service"] = {
        filetypes = { "yaml.docker-compose" },
        root_dir = lsp_util.root_pattern(
          "docker-compose.yml",
          "docker-compose.yaml",
          "compose.yml",
          "compose.yaml",
          ".git"
        ),
      },
      lua_ls = {},
      jsonls = {
        filetypes = { "json" }
      },
      ["nil"] = {},
      pyright = {
        settings = {
          python = {
            venvPath = ".",
            analysis = {
              extraPaths = { "." },
              typeCheckingMode = "off",

              diagnosticSeverityOverrides = {
                reportUntypedFunctionDecorator = "none",
                reportUntypedClassDecorator = "none",
                reportCallIssue = "none",
              },
            },
          },
        },
      },
      black = {},
      jdtls = {},
      -- ["sonarlint-language-server"] = {
      --   -- server = {
      --   --   cmd = {
      --   --     "sonarlint-language-server",
      --   --     "-stdio",
      --   --     "-analyzers",
      --   --     vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
      --   --     vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
      --   --     vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
      --   --     -- add more analyzers as needed
      --   --   },
      --   --
      --   --   -- IMPORTANT: these settings names are from the SonarLint LS itself.
      --   --   -- They include SonarCloud connections + project binding.
      --   --   -- settings = {
      --   --   --   ["sonarlint.connectedMode.connections.sonarcloud"] = {
      --   --   --     {
      --   --   --       organizationKey = "YOUR_ORG_KEY",
      --   --   --       token = os.getenv("SONARCLOUD_TOKEN"),   -- don't hardcode tokens in config 🙂
      --   --   --       -- connectionId = "optional-if-you-have-multiple"
      --   --   --       -- disableNotifications = true,
      --   --   --     },
      --   --   --   },
      --   --   --
      --   --   --   ["sonarlint.connectedMode.project"] = {
      --   --   --     projectKey = "YOUR_SONARCLOUD_PROJECT_KEY",
      --   --   --     -- connectionId = "only if you set multiple connections above"
      --   --   --   },
      --   --   -- },
      --   -- },
      --   --
      --   filetypes = {
      --     "javascript", "javascriptreact",
      --     "typescript", "typescriptreact",
      --     "python",
      --     "java",
      --     -- add more if you added the matching analyzer jar
      --   },
      --
      -- }
    }
    -- after you setup lspconfig
    -- require("sonarlint").setup()

    for name, manual_cfg in pairs(manual_servers) do
      pcall(require, "lspconfig.server_configurations." .. name)
      local cfg = vim.tbl_deep_extend('force',
        { capabilities = capabilities },
        manual_cfg
      )
      vim.lsp.config(name, cfg)
      vim.lsp.enable(name)
    end

    require("mason").setup()
    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          vim.lsp.config(server_name, server)
          vim.lsp.enable(server_name)
        end,
      }
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        --linter
        "eslint-lsp",

        --formatter
        "clang-format",
        "prettier",

        --lsp
        "json-lsp",
        "lua-language-server",

        --debugger
        "codelldb",

      },
    })


    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        map('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')

        map('gv', function()
          vim.cmd('vsplit')
          vim.lsp.buf.definition()
        end, '[G]oto definition [V]ertical split')

        map('<leader>ee', telescope_builtin.lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        map('gi', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')

        map('gq', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

        map("gh", vim.lsp.buf.hover, "[H]over")

        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')


        -- Jump to the type of the word under your cursor.
        map('<leader>D', telescope_builtin.lsp_type_definitions, 'Type [D]efinition')


        -- Fuzzy find all the symbols in your current workspace.
        map('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      end,
    })
  end


}
