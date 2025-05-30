return {
  {
    'mfussenegger/nvim-lint',
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        -- tsx = { "eslint_d" },
      }


      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufReadPre", "BufWritePost" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end
      })

      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end
  },
}
