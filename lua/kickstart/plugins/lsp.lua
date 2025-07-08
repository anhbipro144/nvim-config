return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      'williamboman/mason.nvim',
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
    local servers = {

      lua_ls = {},
      jsonls = {
        filetypes = { "json" }
      },
      ["nil"] = {
        -- cmd = { "/home/neo/.nix-profile/bin/nil" },
        -- filetypes = { "nix" },
      },
      clangd = {
        cmd       = {
          "clangd"
        },
        filetypes = { "c", "cpp" }
      },
    }

    local lspconfig = require("lspconfig")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local file_operation_capabilities = require("lsp-file-operations").default_capabilities()
    local telescope_builtin = require("telescope.builtin")
    -- local cmp_capabilites = require('blink.cmp').get_lsp_capabilities()
    local cmp_capabilites = require('cmp_nvim_lsp').default_capabilities()



    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        map('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')

        map('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')

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

    capabilities = vim.tbl_deep_extend('force', capabilities, file_operation_capabilities, cmp_capabilites)


    require("mason").setup()
    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          lspconfig[server_name].setup(server)
        end,
      }
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        --linter
        "eslint",

        --formatter
        "clang-format",
        "prettier",

        --lsp
        "clangd",
        "json-lsp",
        "lua-language-server",

        --debugger
        "codelldb",

      },
    })
  end


}
