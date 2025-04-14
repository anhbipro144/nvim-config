-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '0', ':Neotree float reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    popup_border_style = "rounded",
    close_if_last_window = true,
    window = {
      mappings = {
        ["<tab>"] = {
          "toggle_node",
          nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
        },
      }
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,                  -- This will show hidden files
        hide_gitignored = false,
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
      },
      window = {
        mappings = {
          ['0'] = 'close_window',
        },
      },
    },
    actions = {
      open_file = {
        quit_on_open = true
      }
    }
  },
}
