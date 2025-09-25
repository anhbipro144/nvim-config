return {
  'booperlv/nvim-gomove',
  config = function()
    require('gomove').setup(
      {
        map_defaults = false,
        reindent = true,
        undojoin = true,
        move_past_end_col = false,
      }
    )
    local map = vim.api.nvim_set_keymap


    map("x", "<", "<Plug>GoVSMLeft", {})
    map("x", ">", "<Plug>GoVSMRight", {})

    map("x", "<S-n>", "<Plug>GoVSMDown", {})
    map("x", "<S-m>", "<Plug>GoVSMUp", {})
  end
}
