return {
  "serhez/bento.nvim",
  config = function()
    local bento_ui = require("bento.ui")
    local bento = require("bento")
    bento.setup({
      main_keymap = "\\",

      ui = {
        mode = "floating", -- "floating" | "tabline"
        floating = {
          position = "middle-left",
          -- offset_x = 75,      -- Horizontal offset
          -- offset_y = -5,      -- Horizontal offset
          -- border = "rounded", -- "rounded" | "single" | "double" | etc
        },
      },

      actions = {
        -- Copy path
        copy_path = {
          key = "y",
          action = function(_, buf_name)
            vim.fn.setreg("+", buf_name)
          end,
        },

        delete = {
          key = "<C-d>",
          action = function(buf_id)
            vim.api.nvim_buf_delete(buf_id, { force = false })
            bento_ui.refresh_menu()
          end,
        },

        vsplit = {
          key = "<C-v>",
          hl = "Boolean",
          action = function(buf_id)
            -- this is what happens when you choose a buffer
            vim.cmd("vsplit")
            vim.api.nvim_set_current_buf(buf_id)
          end,
        },
      }
    })
    vim.keymap.set("n", "q", function()
      bento_ui.close_menu()
    end, { desc = "Close Bento", silent = true })

    vim.keymap.set("n", "BA", function()
      bento.close_all_buffers({ current = false })       -- Keep current buffer open
    end, { desc = "Close all except current", silent = true })
  end
}
