return {
  "rmagatti/goto-preview",
  event = "BufEnter",
  config = function()
    require('goto-preview').setup {
      default_mappings = true
    }
  end
}
