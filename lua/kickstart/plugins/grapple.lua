return {
  "cbochs/grapple.nvim",
  opts = {
    scope = "git",     -- also try out "git_branch"
  },
  event = { "BufReadPost", "BufNewFile" },
  cmd = "Grapple",
  keys = {
    { "<leader>m", "<cmd>Grapple tag<cr>",          desc = "Grapple tag" },
    { "<leader>M", "<cmd>Grapple toggle_tags<cr>",     desc = "Grapple open tags window" },
    { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple cycle next tag" },
    { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple cycle previous tag" },

    { "<A-1>",       "<cmd>Grapple select index=1<cr>",  desc = "Grapple tag 1" },
    { "<A-2>",       "<cmd>Grapple select index=2<cr>",  desc = "Grapple tag 2" },
    { "<A-3>",       "<cmd>Grapple select index=3<cr>",  desc = "Grapple tag 3" },
    { "<A-8>",       "<cmd>Grapple select index=4<cr>",  desc = "Grapple tag 4" },
    { "<A-9>",       "<cmd>Grapple select index=5<cr>",  desc = "Grapple tag 5" },

    -- vim.keymap.set("n", "<leader>1", "<cmd>Grapple select index=1<cr>")
  },
}
