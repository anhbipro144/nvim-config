return {
  'anhbipro144/git-worktree.nvim',
  config = function()
    local worktree = require 'git-worktree'
    local agents = require 'kickstart.agents'
    local nvim_mcp_pipe

    local function get_nvim_mcp_pipe()
      local git_root = vim.fn.systemlist { 'git', 'rev-parse', '--show-toplevel' }[1]
      local root = git_root and vim.v.shell_error == 0 and git_root or vim.fn.getcwd()
      local socket_dir = vim.env.XDG_RUNTIME_DIR or vim.env.TMPDIR or '/tmp'
      local escaped_root = root:gsub('^%s+', ''):gsub('%s+$', ''):gsub('/', '%%')

      return string.format('%s/nvim-mcp.%s.%d.sock', socket_dir, escaped_root, vim.fn.getpid())
    end

    local function refresh_nvim_mcp_pipe()
      local next_pipe = get_nvim_mcp_pipe()

      if nvim_mcp_pipe == next_pipe then
        return
      end

      if nvim_mcp_pipe then
        pcall(vim.fn.serverstop, nvim_mcp_pipe)
      end

      vim.fn.serverstart(next_pipe)
      nvim_mcp_pipe = next_pipe
    end

    nvim_mcp_pipe = get_nvim_mcp_pipe()

    worktree.on_tree_change(function(op, metadata)
      if op == worktree.Operations.Create then
        agents.copy_for_worktree(metadata.path)
        agents.copy_frontend_env_for_worktree(metadata.path)
      elseif op == worktree.Operations.Switch then
        refresh_nvim_mcp_pipe()
      end
    end)
  end,
}
