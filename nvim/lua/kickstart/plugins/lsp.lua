return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    "williamboman/mason-lspconfig.nvim",
    { 'j-hui/fidget.nvim',       opts = {} },
    'hrsh7th/nvim-cmp',
    "hrsh7th/cmp-nvim-lsp"

  },
  config = function()
    local servers = {
      ts_ls = {},
      lua_ls = {},
    }

    local lspconfig = require("lspconfig")
    local ensure_installed = vim.tbl_keys(servers or {})
    -- local capabilities = vim.lsp.protocol.make_client_capabilities()
    local telescope_builtin = require("telescope.builtin")

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')

        -- Find references for the word under your cursor.
        map('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gi', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('gq', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

        map("gh", vim.lsp.buf.hover, "[H]over")

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        map('<leader>d', telescope_builtin.diagnostics, '[G]oto [I]mplementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', telescope_builtin.lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', telescope_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })




    -- vim.api.nvim_create_autocmd('LspAttach', {
    --   group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    --   callback = function(ev)
    --     -- Enable completion triggered by <c-x><c-o>
    --     vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    --
    --     -- Buffer local mappings.
    --     -- See `:help vim.lsp.*` for documentation on any of the below functions
    --     local opts = { buffer = ev.buf }
    --     vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    --     vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    --     vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
    --     vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    --     vim.keymap.set({ 'n', 'v' }, 'gq', vim.lsp.buf.code_action, opts)
    --     vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    --     vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    --     vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    --     vim.keymap.set('n', '<space>wl', function()
    --       print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    --     end, opts)
    --     vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    --     vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    --     vim.keymap.set('n', '<space>f', function()
    --       vim.lsp.buf.format { async = true }
    --     end, opts)
    --   end,
    -- })



    -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())


    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, server.capabilities or {})
          lspconfig[server_name].setup(server)
        end,
      },
    })
  end


}
