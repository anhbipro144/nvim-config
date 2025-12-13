return {
  'chomosuke/term-edit.nvim',
  event = 'TermOpen', -- fires for ToggleTerm terminals too
  version = '1.*',
  config = function()
    require('term-edit').setup({
      prompt_end = '%$ ', -- bash/zsh default prompt ending + space
      -- default_reg = '"',   -- optional: which register to use for yanks
      -- feedkeys_delay = 10, -- increase if shell feels laggy
    })
  end,
}
