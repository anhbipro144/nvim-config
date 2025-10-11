-- Helper function 
local function bind(mode)
  return function(lhs, rhs, silent)
    local options = {
      noremap = true,
      silent = silent or false
    }
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

local nmap = bind('n') -- nnoremap
local imap = bind('i') -- inoremap
local vmap = bind('v') -- vnoremap
local tmap = bind('t') -- tnoremap

-- Set leader key
vim.g.mapleader = ' '

-- LSP keybinds
nmap('<leader>n', vim.diagnostic.goto_next, true)
nmap('<leader>N', vim.diagnostic.goto_prev, true)

-- Move around split windows with less keystrokes
nmap('<c-h>', ':wincmd h<cr>', true)
nmap('<c-j>', ':wincmd j<cr>', true)
nmap('<c-k>', ':wincmd k<cr>', true)
nmap('<c-l>', ':wincmd l<cr>', true)

-- Make working with terminal windows easier
local exit_term = '<c-\\><c-n>'
tmap('<esc>', exit_term, true)
tmap('<c-h>', exit_term..':wincmd h<cr>', true)
tmap('<c-j>', exit_term..':wincmd j<cr>', true)
tmap('<c-k>', exit_term..':wincmd k<cr>', true)
tmap('<c-l>', exit_term..':wincmd l<cr>', true)

-- Create terminal window
nmap('<leader>t', function()
  vim.cmd('new | terminal')
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.cmd('resize 15 | startinsert')
end)

-- Create split panes
nmap('<leader>v', ':vertical new<cr>', true)
nmap('<leader>x', ':new<cr>', true)
nmap('<leader>o', ':wincmd o<cr>', true)

-- Keybinds with shift
nmap('Y', 'y$') -- Yank to the end
nmap('U', ':redo<cr>') -- Redo
vmap('J', 'j')
vmap('K', 'k')

-- Prevent Ctrl-C from canceling block insertion
imap('<c-c>', '<esc>')

-- Toggle light and dark theme
nmap('<c-r>', function()
  if vim.opt.background:get() == 'dark' then
    vim.opt.background = 'light'
  else
    vim.opt.background = 'dark'
  end
end, true)

-- Build project with a command
local make_cmd = 'make'
nmap('<leader>m', function()
  local cmd = vim.fn.input('Build command: ', make_cmd)
  local last_makeprg = vim.opt.makeprg:get()

  vim.opt.makeprg = cmd:match('%S+')
  vim.cmd((cmd:gsub('%S+', 'make', 1)))

  vim.opt.makeprg = last_makeprg
  make_cmd = cmd
end)

