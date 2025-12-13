return {
  "Juksuu/worktrees.nvim",
  config = function()
    local worktree = require("worktrees")

    worktree.setup()


    vim.keymap.set('n', '<leader>ge', worktree.new_worktree, { desc = '[S]earch current [W]ord' })
  end,


}
