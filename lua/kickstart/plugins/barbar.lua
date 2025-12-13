return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.bufremove").setup() -- no opts needed

    -- Close current buffer (keep layout)
    vim.keymap.set("n", "<S-B><S-D>", function()
      require("mini.bufremove").delete(0, false)  -- false = don't force
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
}
