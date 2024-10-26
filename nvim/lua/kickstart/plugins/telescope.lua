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

        -- `build` is used to run some command when the plugin is installed/updated.
        build = "make",

        -- `cond` is a condition used to determine whether this plugin should be installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

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
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close
        },
      }

      local function filename_first_path_display(_, path)
        local tail = vim.fs.basename(path)
        local parent = vim.fs.dirname(path)
        if parent == "." then
          return tail
        else
          return string.format("%s\t\t%s", tail, parent)
        end
      end

      telescope.setup({
        defaults = {
          -- path_display = {
          --   filename_first = {
          --     reverse_directories = false
          --   }
          -- },
          path_display = filename_first_path_display,
          file_ignore_patterns = { "^node_modules/", "^dist/", "^.git/" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<esc>"] = actions.close
            },
          },
        },

        pickers = {
          git_files = {
            theme = theme.dropdown,
          },
          find_files = {
            theme = theme.dropdown,
            hidden = true,
            find_command = {
              "rg",
              "--files",
              "--glob",
              "!{.git/*,.svelte-kit/*,target/*,node_modules/*}",
              "--path-separator",
              "/",
            },
          },

          live_grep = {
            theme = theme.ivy
          },
          buffers = {
            theme = theme.ivy,
            initial_mode = "normal",
            sort_lastused = true,
            mappings = {
              n = {
                ["d"] = actions.delete_buffer,
              },
            },
          },

          diagnostics = {
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


      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>ss', builtin.git_status, { desc = '[S]earch Git [S]tatus' })
      vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = '[S]earch Git file' })

      vim.keymap.set('n', '<leader>sa', builtin.find_files, { desc = '[S]earch [A]ll Files' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })



      vim.keymap.set('n', '<leader>rf', builtin.lsp_references, { desc = '[S]earch [R]eferences' })

      vim.keymap.set('n', '<leader><leader>', builtin.buffers,
        { desc = '[ ] Find existing buffers' })
    end,
  },
}
