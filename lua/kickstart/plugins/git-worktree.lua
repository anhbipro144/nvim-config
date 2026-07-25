return {
  'anhbipro144/git-worktree.nvim',
  config = function()
    local worktree = require 'git-worktree'

    worktree.on_tree_change(function(op, metadata)
      if op ~= worktree.Operations.Create then
        return
      end

      local destination = vim.fn.fnamemodify(metadata.path, ':p') .. '/AGENTS.md'
      local copied, err = vim.uv.fs_copyfile('/home/neo/.codex/AGENTS.md', destination)

      if not copied then
        vim.notify(string.format('Failed to copy AGENTS.md: %s', err), vim.log.levels.ERROR)
      end
    end)
  end,
}
