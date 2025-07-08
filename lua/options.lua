local opt = vim.opt

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- NOTE: This option make the colorschme looks less saturated but messed up the background color of some UI.
-- vim.o.background = ""


-- Line number
opt.number = true
opt.relativenumber = true

-- opt.showtabline = 0

opt.tabstop = 3
opt.softtabstop = 4
opt.shiftwidth = 4

opt.expandtab = true
opt.clipboard = "unnamedplus"

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true

opt.cursorline = true -- Hight current line
opt.termguicolors = true


-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = 'a'


-- Better wrap line
opt.textwidth=80
opt.wrapmargin=0
opt.wrap = true
opt.linebreak = true

-- vim.o.completeopt = "menu,menuone,noselect,noinsert,popup"
