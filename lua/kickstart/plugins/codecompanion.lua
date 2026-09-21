return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion" },
  keys = {
    { "`", "<cmd>CodeCompanionChat Toggle<CR>", desc = "Open CodeCompanion chat buffer" },
    { "<leader>cc", "<cmd>CodeCompanionChat<CR>", desc = "Start a new CodeCompanion chat" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "lalitmee/codecompanion-spinners.nvim",
  },

  config = function()
    local codecompanion = require("codecompanion")

    codecompanion.setup({
      rules = {
        opts = {
          chat = {
            autoload = false,
          },
        },
      },
      interactions = {
        chat = {
          adapter = "codex",
          slash_commands = {
            ["resume"] = {
              path = "codecompanion.resume",
            },
          },
          keymaps = {
            acp_session_options = {
              modes = {
                n = "go",
              },
              description = "ACP session options",
              callback = function(chat)
                local config = require("codecompanion.config")
                local slash_commands =
                    require("codecompanion.interactions.chat.slash_commands")

                slash_commands.run({
                  label = "acp_session_options",
                  config = config.interactions.chat.slash_commands.acp_session_options,
                }, chat)
              end,
            },
            reasoning_effort = {
              modes = {
                n = "ge",
              },
              description = "Change Codex reasoning effort",
              callback = function(chat)
                if not chat.acp_connection then
                  return vim.notify(
                    "No ACP connection available",
                    vim.log.levels.WARN
                  )
                end

                local options = chat.acp_connection:get_config_options()

                local reasoning_option = vim.iter(options):find(function(option)
                  local id = tostring(option.id or ""):lower()
                  local name = tostring(option.name or ""):lower()

                  return id == "thought_level"
                      or id:find("reason", 1, true)
                      or id:find("thought", 1, true)
                      or name:find("reason", 1, true)
                      or name:find("thought", 1, true)
                end)

                if not reasoning_option then
                  return vim.notify(
                    "Reasoning effort option not available",
                    vim.log.levels.WARN
                  )
                end

                local SlashCommand = require(
                  "codecompanion.interactions.chat.slash_commands.builtin.acp_session_options"
                )

                SlashCommand
                    .new({
                      Chat = chat,
                      config = {},
                    })
                    :show_values(reasoning_option)
              end,
            },
            model_selection = {
              modes = {
                n = "gn",
              },
              description = "Change Codex model",
              callback = function(chat)
                if not chat.acp_connection then
                  return vim.notify(
                    "No ACP connection available",
                    vim.log.levels.WARN
                  )
                end

                local model_option = vim.iter(chat.acp_connection:get_config_options()):find(
                  function(option)
                    return tostring(option.id or ""):lower() == "model"
                  end
                )

                if not model_option then
                  return vim.notify(
                    "Model selection option not available",
                    vim.log.levels.WARN
                  )
                end

                local SlashCommand = require(
                  "codecompanion.interactions.chat.slash_commands.builtin.acp_session_options"
                )

                SlashCommand
                    .new({
                      Chat = chat,
                      config = {},
                    })
                    :show_values(model_option)
              end,
            },
          },
          tools = {
            opts = {
              default_tools = {
                "read_file",
                "grep_search",
                "file_search",
                "web_search",
                "fetch_webpage",
              },
              auto_submit_errors = true,
              auto_submit_success = true,
            },
          },
        },
      },
      display = {
        action_palette = {
          opts = {
            show_preset_prompts = false,
          },
        },
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
        spinner = {
          opts = {
            style = "native",
          },
        },
      },
      adapters = {
        acp = {
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "chat-gpt",
                session_config_options = {
                  model = "gpt-5.6-luna",
                  thought_level = "Medium",
                },
              },
            })
          end,
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              commands = {
                default = {
                  "gemini",
                  "--experimental-acp",
                },
              },
              defaults = {
                auth_method = "oauth-personal",
              },
            })
          end,

          copilot_acp = function()
            return require("codecompanion.adapters").extend("copilot_acp", {})
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

    require("codecompanion.tabs").setup()
  end,
}
