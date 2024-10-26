-- Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true


-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move focus to the upper window' })
vim.keymap.set('i', '<C-BS>', '<C-W>', { noremap = true, silent = true })


-- Visual mode editing
vim.keymap.set("v", "N", ":m '>+1<CR>gv=gv") -- Move selection up
vim.keymap.set("v", "M", ":m '<-2<CR>gv=gv") -- Move selection down
vim.keymap.set('v', "<C-n>", "y'>pgv")       -- Duplicate selection

-- Vertical navigate
vim.keymap.set('n', "<C-d>", "<C-d>zz")
vim.keymap.set('n', "<C-u>", "<C-u>zz")


-- Yank into the system clipboard
vim.keymap.set('n', "<leader>y", "\"+y")


-- Map Ctrl+s to save the file
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })
vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>gv', { noremap = true, silent = true })


-- Navigate buffer
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")
vim.keymap.set("n", "<S-l>", ":bnext<CR>")

-- Buffer management
vim.keymap.set('n', "<leader>be", "<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal<CR>") -- Buffer explorer
-- vim.keymap.set('n', '<S-B><S-D>', ':bd<CR>', { noremap = true, silent = true })                                      -- Delete current


-- Past without losing buffer
vim.keymap.set('x', "<leader>p", "\"_dP")

-- Remap Ctrl + z to undo in insert mode
vim.api.nvim_set_keymap('i', '<C-z>', '<C-o>u', { noremap = true, silent = true })




-- vim.keymap.set('n', '<C-w><C-s>', ':bd<Delete currentCR>', { noremap = true, silent = true }) -- Delete current buffer
vim.keymap.set('n', '<S-W><S-H>', ':split<CR>', { noremap = true, silent = true })  -- Horizontal split
vim.keymap.set('n', '<S-W><S-V>', ':vsplit<CR>', { noremap = true, silent = true }) -- Vertical split
vim.keymap.set('n', '<S-W><S-D>', ':close<CR>', { noremap = true, silent = true })  -- Close split



-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
