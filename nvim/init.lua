vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- vim.o.shell = 'C:\\Program Files\\WindowsApps\\Microsoft.PowerShell_7.4.5.0_x64__8wekyb3d8bbwe\\pwsh.exe'

-- [[ Setting options ]]
require 'options'

-- [[ Basic Keymaps ]]
require 'keymaps'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'
