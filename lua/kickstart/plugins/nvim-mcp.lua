local function is_git_transient_editor()
  for _, arg in ipairs(vim.fn.argv()) do
    if arg:match("COMMIT_EDITMSG$")
      or arg:match("MERGE_MSG$")
      or arg:match("git%-rebase%-todo$")
      or arg:match("TAG_EDITMSG$") then
      return true
    end
  end

  return false
end

return {
  "linw1995/nvim-mcp",
  lazy = false,
  config = function()
    if not is_git_transient_editor() then
      require("nvim-mcp").setup({})
    end
  end,
}
