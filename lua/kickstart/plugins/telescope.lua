return {
  {
    'nvim-telescope/telescope.nvim',
    event        = 'VimEnter',
    -- branch = '0.1.x',
    -- tag = '0.1.8',
    cmd          = "Telescope",
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
    config       = function()
      require("git-worktree").setup()

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
          ['<C-d>'] = actions.preview_scrolling_down,
          ['<C-u>'] = actions.preview_scrolling_up,
        },
      }


      telescope.setup({
        defaults = {
          winblend = 0,
          theme = theme.dropdown,
          path_display = {
            filename_first = {
              reverse_directories = true
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
          lsp_references            = {
            theme = theme.dropdown,
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

      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

      vim.keymap.set('n', '<leader>sa', builtin.git_files, { desc = '[S]earch Git File' })

      -- Disabled in favor of fff.nvim
      -- vim.keymap.set('n', '<leader>so', builtin.find_files, { desc = '[S]earch All [F]iles' })

      vim.keymap.set('n', '<leader>s.', function()
        require('telescope.builtin').find_files({
          prompt_title = "Hidden Files",
          find_command = { 'fd', '--hidden', '--type', 'f' },
          no_ignore = true,
        })
      end, { desc = 'Search hidden files' })

      vim.keymap.set('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = '[S]earch Current [B]uffer' })

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

      vim.keymap.set("n", "<leader>sr", telescope.extensions.git_worktree.git_worktrees,
        { desc = "Open Git worktree" })

      vim.keymap.set("n", "<leader>sR", telescope.extensions.git_worktree.create_git_worktree,
        { desc = "Create git worktree" })
    end,
  },
}
