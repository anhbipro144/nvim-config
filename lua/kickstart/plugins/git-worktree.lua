return {
  'anhbipro144/git-worktree.nvim',
  config = function()
    local worktree = require 'git-worktree'
    local agents = require 'kickstart.agents'

    worktree.on_tree_change(function(op, metadata)
      if op ~= worktree.Operations.Create then
        return
      end

      agents.copy_for_worktree(metadata.path)
    end)
  end,
}
