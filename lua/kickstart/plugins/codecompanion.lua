return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- {
    --   -- use a local directory for development
    --   dir = "/home/neo/personal/learn/codecompanion-history.nvim",
    --   dependencies = {
    --     "nvim-telescope/telescope.nvim", -- for telescope picker
    --   },
    --
    -- },
    "ravitemer/codecompanion-history.nvim",
    "github/copilot.vim",
  },

  config = function()
    require("codecompanion.spinner"):init()
    local codecompanion = require("codecompanion")
    codecompanion.setup({
      display = {
        chat = {
          auto_scroll = false
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          keymaps = {
            close = {
              modes = {
                n = "q",
              },
            },
          },

          tools = {
            groups = {
              ["vec_tools"] = {
                description = "Vectorcode tools group - Can query,  list files in vector database, ls indexed projects",
                tools = {
                  "vectorcode_files_ls",
                  "vectorcode_query",
                  "vectorcode_ls",
                },
                opts = {
                  collapse_tools = true,
                },
              }
            },

            opts = {
              default_tools = {
                "web_search",
              },
              auto_submit_errors = false,
              auto_submit_success = false,
            },
          }
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            save_chat_keymap = "sc",
            auto_save = true,
            expiration_days = 3,
            picker = "telescope",
            auto_generate_title = false,
            -- title_generation_opts = {
            --   adapter = nil,               -- "copilot"
            --   model = nil,                 -- "gpt-4o"
            --   refresh_every_n_prompts = 3, -- e.g., 3 to refresh after every 3rd user prompt
            --   max_refreshes = 3,
            -- },
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            enable_logging = false,
            chat_filter = nil, -- function(chat_data) return boolean end
            picker_keymaps = {
              rename = {
                n = "r",
                i = "<C-r>",
              },
              delete = {
                n = "d",
                i = "<C-d>",
              },
            },
          }
        },
        vectorcode = {
          opts = {
            tool_opts = {
              query = {
                chunk_mode = true,
                use_lsp = true,
              },
            }
          }
        }
      },
      adapters = {
        xai = function()
          return require("codecompanion.adapters").extend("xai", {
            env = {
              api_key = os.getenv("GROK_API_KEY")
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
                default = "gpt-5",
              },
            },
          })
        end,

        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = os.getenv("OPENAI_API_KEY")
            },

            schema = {
              model = {
                default = function()
                  return "gpt-5"
                end,
              },
            },
          })
        end,

        tavily = function()
          return require("codecompanion.adapters").extend("tavily", {
            env = {
              api_key = os.getenv("TAVILY")
            },
          })
        end,
      },

    })


    vim.keymap.set("n", "<leader>ch", function()
      codecompanion.extensions.history.browse_chats(nil)
    end, { desc = "Open CodeCompanion history picker" })

    vim.keymap.set("n", "<leader>cp", function()
      codecompanion.toggle()
    end, { desc = "Open CodeCompanion history picker" })

    -- vim.keymap.set("n", "<leader>cp", ":CodeCompanionChat<CR>", { desc = "Open CodeCompanion chat" })
  end
}
