return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build        = "make install_jsregexp",
            dependencies = {
                "rafamadriz/friendly-snippets"
            }
        },
        "onsails/lspkind.nvim",
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
    },
    config = function()
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'



        require('luasnip.loaders.from_vscode').load() -- Load friendly-snippets

        -- luasnip.config.setup {}
        -- luasnip.filetype_extend("typescript", { "javascript" })
        luasnip.filetype_extend("typescript", { "tsdoc" })
        luasnip.filetype_extend("javascript", { "jsdoc" })

        -- luasnip.filetype_extend("typescriptreact", { "html" })

        cmp.setup {
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            completion = { completeopt = 'menu,menuone,noinsert' },
            formatting = {
                format = require('lspkind').cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                    ellipsis_char = '...',
                    show_labelDetails = true
                })

            },

            -- For an understanding of why these mappings were
            -- chosen, you will need to read `:help ins-completion`
            mapping = cmp.mapping.preset.insert {
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-k>'] = cmp.mapping.select_prev_item(),

                -- Scroll the documentation window [b]ack / [f]orward
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-u>'] = cmp.mapping.scroll_docs(4),

                ['<CR>'] = cmp.mapping.confirm { select = true },
                ['<C-Space>'] = cmp.mapping.complete {},


                -- Think of <c-l> as moving to the right of your snippet expansion.
                --  So if you have a snippet that's like:
                --  function $name($args)
                --    $body
                --  end
                --
                -- <c-l> will move you to the right of each of the expansion locations.
                -- <c-h> is similar, except moving you backwards.
                -- ['<C-l>'] = cmp.mapping(function()
                --   if luasnip.expand_or_locally_jumpable() then
                --     luasnip.expand_or_jump()
                --   end
                -- end, { 'i', 's' }),
                -- ['<C-h>'] = cmp.mapping(function()
                --   if luasnip.locally_jumpable(-1) then
                --     luasnip.jump(-1)
                --   end
                -- end, { 'i', 's' }),
                --
                -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'path' },
                { name = 'render-markdown' },
            }, {
                { name = "buffer" }
            }),
        }


        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline({
                ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
                ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),

                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-u>'] = cmp.mapping.scroll_docs(4),

                ['<CR>'] = cmp.mapping.confirm { select = true },

                ['<C-y>'] = cmp.mapping.complete {},

            }),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            }),
            matching = { disallow_symbol_nonprefix_matching = false }
        })
    end,
}
