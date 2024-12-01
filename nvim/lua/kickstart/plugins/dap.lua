local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
}

return {
  { "nvim-neotest/nvim-nio" },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {
        -- codelldb = function(config)
        --   config.adapters = {
        --     name = 'LLDB: Launch',
        --     type = 'codelldb',
        --     request = 'launch',
        --     program = function()
        --       local dir = vim.fn.expand("%:p:h")
        --       return vim.fn.input('Path to executable: ', dir .. '/', 'file')
        --       -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        --     end,
        --     cwd = '${workspaceFolder}',
        --     stopOnEntry = false,
        --     args = {},
        --     console = 'integratedTerminal',
        --   }
        --   require('mason-nvim-dap').default_setup(config) -- don't forget this!
        -- end,
        codelldb = function(config)
          config.configurations = {
            {
              name = 'Launch',
              type = 'codelldb',
              request = 'launch',
              program = function()
                -- Get the directory of the current file and prompt for the executable within it
                local output_dir = vim.fn.expand("%:p:h")
                local output_file = output_dir .. "/" .. vim.fn.expand("%:t:r")

                return vim.fn.input('Path to executable: ', output_file, 'file')
              end,
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
              args = {},
              console = 'integratedTerminal',
            }, }
          require('mason-nvim-dap').default_setup(config) -- don't forget this!
        end,
      }
    }
  },

  -- codelldb = {
  --   {
  --     name = 'LLDB: Launch',
  --     type = 'codelldb',
  --     request = 'launch',
  --     program = function()
  --       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  --     end,
  --     cwd = '${workspaceFolder}',
  --     stopOnEntry = false,
  --     args = {},
  --     console = 'integratedTerminal',
  --   },
  -- }
  --

  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      vim.keymap.set('n', '<leader>dc', dap.continue, { silent = true })
      vim.keymap.set('n', '<leader>ds', dap.step_over, { silent = true })
      vim.keymap.set('n', '<leader>di', dap.step_into, { silent = true })
      vim.keymap.set('n', '<leader>do', dap.step_out, { silent = true })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { silent = true })

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })


      dap.set_log_level("DEBUG")

      -- dap.configurations.cpp = {
      --   {
      --     name = "Launch",
      --     type = "lldb",
      --     request = "launch",
      --     program = function()
      --       return vim
      --           .fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      --     end,
      --     cwd = '${workspaceFolder}',
      --     stopOnEntry = false,
      --     args = {},
      --     runInTerminal = true,
      --   } }

      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          -- Debug  nodejs lauch
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            protocol = 'inspector',
            console = 'integratedTerminal',
          },
          -- Debug nodejs process attach (add --inspect when run the process)
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            runtimeExecutable = "node",
            address = "0.0.0.0",
            port = 9229,
            protocol = 'inspector',
            restart = true, -- Automatically reattach if the process restarts console = 'integratedTerminal',
            reAttach = true,
          },
          -- Debug client lauch Chrome
          {
            name = 'Debug Next.js with Chrome',
            type = 'pwa-chrome',
            request = 'launch',
            url = 'http://localhost:3001',
            webRoot = '${workspaceFolder}',
            runtimeExecutable = '/usr/bin/google-chrome',
            runtimeArgs = {
              '--remote-debugging-port=9222',
              '--enable-features=UseOzonePlatform',
              '--ozone-platform=wayland' },
            skipFiles = { '<node_internals>/**' }
          },

          -- Debug client attach (add --inspect when the process)
          {
            name = 'Debug attach to Chrome ',
            type = 'pwa-chrome',
            request = 'attach',
            host = "127.0.0.1",
            url = 'http://localhost:3001',
            -- port = 9222,
            webRoot = '${workspaceFolder}',
            skipFiles = { '<node_internals>/**' },

          },
        }
      end
    end,
    keys = {
      {
        "<leader>da",
        function()
          if vim.fn.filereadable(".vscode/launch.json") then
            local dap_vscode = require("dap.ext.vscode")
            dap_vscode.load_launchjs(nil, {
              ["pwa-node"] = js_based_languages,
              ["chrome"] = js_based_languages,
              ["pwa-chrome"] = js_based_languages,
            })
          end
          require("dap").continue()
        end,
        desc = "Run with Args",
      },
    },
    dependencies = {
      -- Install the vscode-js-debug adapter
      {
        "microsoft/vscode-js-debug",
        -- After install, build it and rename the dist directory to out
        build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
        version = "1.*",
      },
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("dap-vscode-js").setup({
            -- Path of node executable. Defaults to $NODE_PATH, and then "node"
            -- node_path = "node",

            debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

            -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
            -- debugger_cmd = { "js-debug-adapter" },

            adapters = {
              "chrome",
              "pwa-node",
              "pwa-chrome",
              "pwa-firefox",
              "pwa-msedge",
              "pwa-extensionHost",
              "node-terminal",
            },

            -- Path for file logging
            -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

            -- Logging level for output to file. Set to false to disable logging.
            -- log_file_level = false,

            -- Logging level for output to console. Set to false to disable console output.
            -- log_console_level = vim.log.levels.ERROR,
          })
        end,
      },
      {
        "Joakker/lua-json5",
        build = "./install.sh",
      },

      {
        "rcarriga/nvim-dap-ui",
        event = "VeryLazy",
        dependencies = "mfussenegger/nvim-dap",
        config = function()
          local dap = require("dap")
          local dapui = require("dapui")
          require("dapui").setup({
            layouts =
            { {
              elements = {
                { id = "breakpoints", size = 0.15 },
                -- { id = "stacks",      size = 0.25 },
                { id = "watches",     size = 0.25 },
                { id = "scopes",      size = 0.5 },
                { id = "repl",        size = 0 },
              },
              position = "left",
              size = 40
            },
              -- {
              --   elements = {
              --     { id = "repl", size = 1 },
              --     -- { id = "console", size = 0.5 }
              --   },
              --   position = "top",
              --   size = 1
              -- }
            },
          })
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end
      },

    },
  },
}
