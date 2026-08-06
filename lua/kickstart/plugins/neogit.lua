return {
  "NeogitOrg/neogit",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    -- "nvim-telescope/telescope.nvim",
  },
  keys = {
    { '<leader>gg', '<cmd>Neogit<CR>', mode = 'n', desc = 'Open Neogit' }
  },
  cmd = "Neogit",
  config = function()
    local neogit = require("neogit")
    local agents = require("kickstart.agents")
    -- local telescope_config = require("telescope")

    neogit.setup({
      telescope_sorter = nil,
      graph_style = "kitty",
      integrations = {
        diffview = true,
        telescope = nil
      },

      mappings = {
        finder = {
          ["<cr>"] = "Select",
          ["<c-j>"] = "Next",
          ["<c-k>"] = "Previous",
        },
      }
    })

    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("CopyWorktreeAgents", { clear = true }),
      pattern = "NeogitWorktreeCreate",
      callback = function(args)
        agents.copy_for_worktree(args.data.new_cwd)
      end,
    })
  end,
}
