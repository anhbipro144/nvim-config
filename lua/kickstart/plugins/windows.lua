return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    "anuvyklack/animation.nvim"
  },
  config = function()
    vim.o.winwidth = 10
    vim.o.winminwidth = 10
    vim.o.equalalways = false
    require('windows').setup({
      animation = {
        duration = 150,
        fps = 60,
      }


    })

    local function cmd(command)
      return table.concat({ '<Cmd>', command, '<CR>' })
    end

    vim.keymap.set('n', '<S-A-d>', cmd 'WindowsMaximize')
    vim.keymap.set('n', '<C-w>_', cmd 'WindowsMaximizeVertically')
    vim.keymap.set('n', '<C-w>|', cmd 'WindowsMaximizeHorizontally')
    vim.keymap.set('n', '<C-w>=', cmd 'WindowsEqualize')
  end
}
