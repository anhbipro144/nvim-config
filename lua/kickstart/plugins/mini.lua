return {
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      require('mini.indentscope').setup({
        symbol = "│",
      })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- Buf
      require("mini.bufremove").setup() -- no opts needed

      -- Close current buffer (keep layout)
      vim.keymap.set("n", "<S-B><S-D>", function()
        require("mini.bufremove").delete(0, false) -- false = don't force
      end, { silent = true })

      -- Simple “restore last closed buffer” stack (no plugin)
      local closed = {}
      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(args)
          -- record file path if it exists
          local name = vim.api.nvim_buf_get_name(args.buf)
          if name ~= "" then table.insert(closed, 1, name) end
        end,
      })
      vim.keymap.set("n", "<S-B><S-R>", function()
        local path = table.remove(closed, 1)
        if path then vim.cmd.edit(vim.fn.fnameescape(path)) end
      end, { silent = true })
    end,

  },
}
