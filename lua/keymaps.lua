-- Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true




vim.keymap.set('n', "<S-h>", '^', { noremap = true })
vim.keymap.set('n', "<S-l>", '$', { noremap = true })

vim.keymap.set("n", "<S-_>", ":vertical resize -10<CR>", { noremap = true })
vim.keymap.set("n", "<S-+>", ":vertical resize +10<CR>", { noremap = true })

-- Increment/decrement
vim.keymap.set("n", "=", "<C-a>")
vim.keymap.set("n", "-", "<C-x>")

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move focus to the upper window' })

-- Delete word in insert mode
vim.keymap.set('i', '<C-BS>', '<C-W>', { noremap = true, silent = true })

-- Create new blank line with Ctrl + enter
vim.keymap.set('n', '<C-CR>', 'o<Esc>', { noremap = true, silent = true })

-- Visual mode editing
vim.keymap.set("v", "N", ":m '>+1<CR>gv=gv") -- Move selection up
vim.keymap.set("v", "M", ":m '<-2<CR>gv=gv") -- Move selection down
vim.keymap.set('v', "<C-n>", "y'>pgv")       -- Duplicate selection


-- Vertical navigate
vim.keymap.set('n', "<C-d>", "<C-d>zz")
vim.keymap.set('n', "<C-u>", "<C-u>zz")

-- Diffview
vim.keymap.set('n', '<leader>gc', '<Cmd>DiffviewOpen<CR>', { noremap = true, silent = true })


-- Map Ctrl+s to save the file
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, silent = true })
vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>gv', { noremap = true, silent = true })

vim.keymap.set('x', "<leader>p", "\"_dP")                                 -- Paste without losing buffer
vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true }) -- Remap Ctrl + z to undo in insert mode

-- Split
vim.keymap.set('n', '<S-W><S-H>', ':vsplit<CR>', { noremap = true, silent = true }) -- Horizontal split
vim.keymap.set('n', '<S-W><S-V>', ':split<CR>', { noremap = true, silent = true })  -- Vertical split
vim.keymap.set('n', '<S-W><S-D>', ':close<CR>', { noremap = true, silent = true })  -- Close split


-- Persistence
vim.keymap.set("n", "<leader>ql", function() require("persistence"):load({ last = true }) end) -- Load the last session
vim.keymap.set("n", "<leader>qs", function() require("persistence"):load() end)                -- Load the session for the current directory


vim.keymap.set("n", "<leader>ms", ':Mason<CR>', { noremap = true, silent = true }) -- Open Mason
vim.keymap.set("n", "<leader>lz", ':Lazy<CR>', { noremap = true, silent = true })  -- Open Lazy

-- Highlight when yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
