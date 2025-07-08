return {
  {
    'nvim-telescope/telescope.nvim',
    -- event = 'VimEnter',
    -- branch = '0.1.x',
    -- tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = "make",
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("git-worktree").setup()

      -- See `:help telescope` and `:help telescope.setup()`
      local actions = require("telescope.actions")
      local telescope = require("telescope")
      local builtin = require('telescope.builtin')

      local theme = {
        ivy = "ivy",
        dropdown = "dropdown"
      }
      local default_mapping = {
        i = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close,
          ["<C-d>"] = false,
          ["<C-u>"] = false,
        },
      }


      telescope.setup({
        defaults = {
          theme = theme.dropdown,
          path_display = {
            filename_first = {
              reverse_directories = false
            }
          },
          file_ignore_patterns = { "^node_modules/", "^dist/", "^.git/", "^.next/" },
          mappings = default_mapping,
        },
        pickers = {
          git_files                 = {
            theme = theme.dropdown,
          },
          find_files                = {
            theme     = theme.dropdown,
            hidden    = true,
            no_ignore = true
          },

          live_grep                 = {
            theme = theme.ivy
          },
          history                   = {
            theme = theme.dropdown,
          },
          buffers                   = {
            theme = theme.ivy,
            initial_mode = "normal",
            sort_lastused = true,
            mappings = {
              n = {
                ["d"] = actions.delete_buffer,
              },
            },
          },
          lsp_document_symbols      = {
            theme = theme.dropdown,
            previewer = false,
          },
          current_buffer_fuzzy_find = {
            theme = theme.dropdown,
          },
          diagnostics               = {
            theme = theme.ivy
          }
        },

        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          }
        },

      })



      telescope.load_extension("git_worktree")
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      -- vim.keymap.set('n', '<leader>sgs', builtin.git_status, { desc = '[S]earch Git [S]tatus' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = '[S]earch Document [S]ymbols' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

      vim.keymap.set('n', '<leader>sa', builtin.git_files, { desc = '[S]earch Git File' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch All [F]iles' })
      vim.keymap.set('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = '[S]earch Current [B]uffer' })

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })


      vim.keymap.set("n", "<Leader>sr", "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
        { desc = "Open Git worktree" })
      vim.keymap.set("n", "<Leader>sR", "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
        { desc = "Create git worktree" })

      vim.keymap.set('n', '<leader><leader>', builtin.buffers,
        { desc = '[ ] Find existing buffers' })
    end,
  },
}
