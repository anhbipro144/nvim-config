return {
  "olimorris/codecompanion.nvim",
  tag = "v18.7.0",
  pin = true,
  cmd = { "CodeCompanion" },
  keys = {
    { "`",          "<cmd>CodeCompanionChat Toggle<CR>", desc = "Open CodeCompanion chat buffer" },
    { "<leader>ch", "<cmd>CodeCompanionHistory<CR>",     desc = "Open CodeCompanion history picker" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/codecompanion-history.nvim",
    "github/copilot.vim",
    "ravitemer/mcphub.nvim"
  },

  config = function()
    require("codecompanion.spinner"):init()
    local codecompanion = require("codecompanion")

    codecompanion.setup({
      interactions = {
        chat = {
          adapter = "copilot",
          tools = {
            opts = {
              default_tools = {
                "read_file",
                "grep_search",
                "file_search",
                "web_search",
                "fetch_webpage",
                -- "vectorcode_toolbox",
              },
              auto_submit_errors = true,
              auto_submit_success = true,
            },
          },
        },
      },
      display = {
        chat = {
          auto_scroll = false,
          window = {
            layout = "float",
            height = 0.9,
            width = 0.9,
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_tools = true,
            show_server_tools_in_chat = true,
            add_mcp_prefix_to_tool_names = false,
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            save_chat_keymap = "sc",
            auto_save = true,
            expiration_days = 3,
            picker = "telescope",
            auto_generate_title = true,
            title_generation_opts = {
              adapter = "copilot",
              model = "gpt-5-mini",
              refresh_every_n_prompts = 3,
              max_refreshes = 3,
            },
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            enable_logging = false,
            chat_filter = nil,
            picker_keymaps = {
              rename = {
                i = "<C-r>",
              },
              delete = {
                i = "<C-S-D>",
              },
            },
          },
        },
        vectorcode = {
          opts = {
            tool_group = {
              enabled = true,
              extras = {},
              collapse = false,
            },
            tool_opts = {
              ["*"] = {},
              ls = {},
              vectorise = {},
              query = {
                max_num = { chunk = -1, document = -1 },
                default_num = { chunk = 50, document = 10 },
                include_stderr = false,
                use_lsp = true,
                no_duplicate = true,
                chunk_mode = true,
                summarise = {
                  enabled = false,
                  adapter = nil,
                  query_augmented = true,
                },
              },
              files_ls = {},
              files_rm = {},
            },
          },
        },
      },
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "chatgpt",
              },
              env = {
                OPENAI_API_KEY = "OPENAI_API_KEY",
              },
            })
          end,
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                auth_method = "oauth-personal",
              },
            })
          end,
        },
        http = {
          xai = function()
            return require("codecompanion.adapters").extend("xai", {
              env = {
                api_key = os.getenv("GROK_API_KEY"),
              },
              schema = {
                model = {
                  default = function()
                    return "grok-3-mini"
                  end,
                },
              },
            })
          end,

          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "gpt-5-mini",
                },
              },
            })
          end,

          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = os.getenv("OPENAI_API_KEY"),
              },
              schema = {
                model = {
                  default = "gpt-5.1",
                },
              },
            })
          end,

          openai_responses = function()
            return require("codecompanion.adapters").extend("openai_responses", {
              schema = {
                model = { default = "gpt-5.1" }, -- or "gpt-5.1"
              },
            })
          end,

          tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
              env = {
                api_key = os.getenv("TAVILY"),
              },
            })
          end,
        },
      },
    })
  end,
}
