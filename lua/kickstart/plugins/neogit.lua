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
        local new_cwd = args.data.new_cwd

        agents.copy_for_worktree(new_cwd)

        vim.system({ "codegraph", "init" }, { cwd = new_cwd }, function(result)
          if result.code ~= 0 then
            vim.schedule(function()
              vim.notify(
                "codegraph init failed:\n" .. result.stderr,
                vim.log.levels.ERROR
              )
            end)
          end
        end)
      end,
    })
  end,
}
