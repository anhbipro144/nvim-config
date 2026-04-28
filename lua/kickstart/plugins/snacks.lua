---@diagnostic disable: undefined-global
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Enable only what we need
    gh = { enabled = true },
    picker = { enabled = true },

    -- Explicitly disable everything else (optional, but makes intent crystal-clear)
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
    -- (and any other modules you might have enabled elsewhere)
  },
  keys = {
    -- PRs / Issues
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub PRs (open)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub PRs (all)" },
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
  },
}
