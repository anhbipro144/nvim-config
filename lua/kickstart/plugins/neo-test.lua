return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "haydenmeade/neotest-jest",
  },
  keys = {
    {
      "<leader>nr",
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      desc = "Run File Tests",
    },
    {
      "<leader>nl",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Run Last Test",
    },
    {
      "<leader>nL",
      function()
        require("neotest").run.run_last({ strategy = "dap" })
      end,
      desc = "Debug Last Test",
    },
    {
      "<leader>nw",
      "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
      desc = "Run Watch",
    },
    {
      "<leader>no",
      function()
        require("neotest").output.open()
      end,
      desc = "Open Neotest Output",
    },
    -- {
    --   "<leader>np",
    --   function()
    --     require("neotest").output_panel.toggle()
    --   end,
    --   desc = "Toggle Neotest Panel",
    -- },
    {
      "<leader>nn",
      function()
        require("neotest").run.run()
      end,
      desc = "Run Nearest Test",
    },
    {
      "<leader>nN",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Debug Nearest Test",
    },
  },
  config = function()
    local neotest = require("neotest")

    -- vim.opt.signcolumn = "yes"
    neotest.setup({
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      quickfix = {
        enabled = false,
      },
      adapters = {
        require('neotest-jest')({
          jestCommand = "npm test --",
          jestArguments = function(defaultArguments, context)
            return defaultArguments
          end,
          jestConfigFile = "jest.config.js",
          cwd = function()
            return vim.fn.getcwd()
          end,
        }),
      }
    })


    -- vim.api.nvim_create_autocmd("BufRead", {
    --   pattern = { "*.test.ts", "*.test.tsx", "*.spec.ts", "*.spec.tsx", "*.test.js", "*.test.jsx" },
    --   callback = function(args)
    --     vim.bo[args.buf].buflisted = true
    --   end,
    -- })

    vim.keymap.set("n", "<leader>np", function()
      neotest.output.open({
        enter = true,
        last_run = true,
        auto_close = true,
        open_win = function(opts)
          local uiw, uih = vim.o.columns, vim.o.lines
          local width    = math.floor((opts.width or uiw * 0.9))
          local height   = math.floor((opts.height or uih * 0.6))
          local row      = math.floor((uih - height) / 2 - 1)
          local col      = math.floor((uiw - width) / 2)

          local tmp      = vim.api.nvim_create_buf(false, true)
          local win      = vim.api.nvim_open_win(tmp, true, {
            relative = "editor",
            style = "minimal",
            border = "rounded",
            width = width,
            height = height,
            row = row,
            col = col,
            title = " neotest output ",
            title_pos = "center",
          })

          vim.schedule(function()
            if not vim.api.nvim_win_is_valid(win) then return end
            local out_buf = vim.api.nvim_win_get_buf(win)
            vim.keymap.set("n", "q", function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
              end
            end, { buffer = out_buf, nowait = true, silent = true })
          end)

          return win
        end

      })
    end, { desc = "Neotest Output (float)" })
  end

}
