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
        codelldb = function(config)
          config.configurations = {
            {
              name = 'Launch',
              type = 'codelldb',
              request = 'launch',
              program = function()
                local output_dir = vim.fn.expand("%:p:h")
                local output_file = output_dir .. "/" .. vim.fn.expand("%:t:r")
                return vim.fn.input('Path to executable: ', output_file, 'file')
              end,
              cwd = '${workspaceFolder}',
              stopOnEntry = false,
              args = {},
              console = 'integratedTerminal',
            }, }
          require('mason-nvim-dap').default_setup(config)
        end,
      }
    }
  },


  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dapvt = require("nvim-dap-virtual-text")

      local opts = { noremap = true, silent = true }

      vim.keymap.set('n', '<leader>dc', dap.continue, opts)
      vim.keymap.set('n', '<leader>dd', dap.step_over, opts)
      vim.keymap.set('n', '<leader>di', dap.step_into, opts)
      vim.keymap.set('n', '<leader>do', dap.step_out, opts)
      vim.keymap.set('n', '<leader>dt', dap.terminate, opts)
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, opts)
      vim.keymap.set("n", "<leader>dr", dap.restart, opts)

      vim.keymap.set("n", "<leader>de", dapui.eval, opts)
      vim.keymap.set("n", "<leader>du", dapui.open, opts)
      vim.keymap.set("n", "<leader>dx", dapui.close, opts)


      vim.keymap.set("n", "<leader>dw", function()
        dapui.float_element('watches', { enter = true })
      end, opts)

      vim.keymap.set("n", "<leader>ds", function()
        dapui.float_element('scopes', { enter = true })
      end, opts)

      vim.keymap.set("n", "<leader>dk", function()
        dapui.float_element('repl', { enter = true })
      end, opts)


      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })


      dap.set_log_level("DEBUG")

      dapvt.setup({
        virt_text_pos = 'inline'
      })

      dapui.setup({
        element_mappings = {
          scopes = {
            expand = { "<Tab>" },
            -- Set the expand key to Tab for the scopes element
          }
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
        },
        windows = { indent = 1 },

        render = {
          max_type_length = nil, -- Can be integer or nil.
        },
      })

      for _, language in ipairs(js_based_languages) do
        dap.configurations[language] = {
          -- Debug nodejs process attach (add --inspect when run the process)
          {
            name = "Debug Backend attach",
            type = "pwa-node",
            request = "attach",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            runtimeExecutable = "node",
            address = "0.0.0.0",
            port = 9229,
            protocol = 'inspector',
            restart = true,
            reAttach = true,
          },
          -- Debug  nodejs lauch (untested)
          {
            name = "Debug Backend lauch",
            type = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            protocol = 'inspector',
            console = 'integratedTerminal',
          },
          -- Debug client lauch Chrome
          {
            name = 'Debug lauch with Chrome',
            type = 'pwa-chrome',
            request = 'launch',
            url = 'http://localhost:3001',
            webRoot = '${workspaceFolder}',
            -- Change to your prefer OS.
            runtimeExecutable = '/usr/bin/google-chrome',
            runtimeArgs = {
              '--remote-debugging-port=9222',
              -- Only need these 2 below on Wayland.
              '--enable-features=UseOzonePlatform',
              '--ozone-platform=wayland' },
            skipFiles = { '<node_internals>/**' }
          },

          -- Debug client attach (add --inspect when the process) (untested)
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
      {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
        version = "1.*",
      },
      {
        "mxsdev/nvim-dap-vscode-js",
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("dap-vscode-js").setup({

            debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),


            adapters = {
              "chrome",
              "pwa-node",
              "pwa-chrome",
              "pwa-firefox",
              "pwa-msedge",
              "pwa-extensionHost",
              "node-terminal",
            },

          })
        end,
      },
      {
        "Joakker/lua-json5",
        build = "./install.sh",
      },
      "theHamsta/nvim-dap-virtual-text",
      "rcarriga/nvim-dap-ui",
    },
  },
}
