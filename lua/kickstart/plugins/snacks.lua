---@diagnostic disable: undefined-global
local function current_git_root()
  return Snacks.git.get_root() or vim.fn.getcwd()
end

local function superproject_root(root)
  local ok, result = pcall(function()
    return vim
      .system({ 'git', 'rev-parse', '--show-superproject-working-tree' }, {
        cwd = root,
        text = true,
        stderr = false,
      })
      :wait()
  end)

  if ok and result.code == 0 then
    local superproject = vim.trim(result.stdout)
    if superproject ~= '' then
      return superproject
    end
  end

  return root
end

local function open_lazygit(root)
  Snacks.lazygit { cwd = root }
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    gh = { enabled = true },
    lazygit = { enabled = true },
    picker = { enabled = true },

    bigfile = { enabled = false },
    scratch = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  keys = {
    {
      '<leader>gp',
      function()
        Snacks.picker.gh_pr()
      end,
      desc = 'GitHub PRs (open)',
    },
    {
      '<leader>gP',
      function()
        Snacks.picker.gh_pr { state = 'all' }
      end,
      desc = 'GitHub PRs (all)',
    },
    {
      '<leader>gi',
      function()
        Snacks.picker.gh_issue()
      end,
      desc = 'GitHub Issues (open)',
    },
    {
      '<leader>gI',
      function()
        Snacks.picker.gh_issue { state = 'all' }
      end,
      desc = 'GitHub Issues (all)',
    },
    {
      '<leader>gl',
      function()
        open_lazygit(current_git_root())
      end,
      desc = 'LazyGit Current Repo',
    },
    {
      '<leader>gL',
      function()
        local root = current_git_root()
        open_lazygit(superproject_root(root))
      end,
      desc = 'LazyGit Superproject',
    },
  },
}
