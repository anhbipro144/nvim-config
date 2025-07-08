-- vim.o.shell = 'C:\\Program Files\\WindowsApps\\Microsoft.PowerShell_7.4.5.0_x64__8wekyb3d8bbwe\\pwsh.exe'

-- [[ Setting options ]]
require 'options'


-- [[ Basic Keymaps ]]
require 'keymaps'

require 'customs'

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap'

-- [[ Configure and install plugins ]]
require 'lazy-plugins'



-- function LogVariable()
--     local variable_name = vim.fn.expand('<cword>')
--
--     local log_statement = 'console.log("' .. variable_name .. ' >>>> ", ' .. variable_name .. ');'
--
--     local line_number = vim.api.nvim_win_get_cursor(0)[1]
--
--     vim.api.nvim_buf_set_lines(0, line_number, line_number, false, { log_statement })
-- end
--
-- -- Bind the LogVariable function to <leader>l
-- vim.keymap.set('n', '<leader>l', ':lua LogVariable()<CR>', { noremap = true, silent = true })
--
--
--
-- vim.diagnostic.config {
--     signs = true,
--     underline = true,
--     virtual_text = true,
--     virtual_lines = true,
--     update_in_insert = true,
--     float = {
--         -- UI.
--         header = false,
--         border = 'rounded',
--         focusable = true,
--     } }
--
-- vim.keymap.set('n', '<leader>do', function()
--     vim.diagnostic.open_float({ border = 'rounded' })
-- end, { noremap = true, silent = true })
