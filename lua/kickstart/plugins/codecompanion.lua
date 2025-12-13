return {
  "olimorris/codecompanion.nvim",
  -- version = "v17.25.0",
  cmd = { "CodeCompanion" },
  keys = {
    { "`",          "<cmd>CodeCompanion<CR>",         desc = "Open CodeCompanion chat buffer" },
    { "<leader>ch", "<cmd>CodeCompanion history<CR>", desc = "Open CodeCompanion history picker" },
  },
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
          auto_scroll = false,
          window = {
            layout = "float", -- float|vertical|horizontal|buffer
            height = 0.9,
            width = 0.9,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "copilot",
          keymaps = {
            -- close = {
            --   modes = {
            --     n = "q",
            --   },
            -- },
          },

          tools = {
            opts = {
              default_tools = {
                "read_file",
                "grep_search",
                "file_search",
                "search_web",
                "fetch_webpage",
                "vectorcode_vectorise"
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
            title_generation_opts = {
              adapter = nil, -- "copilot"
              model = nil,   -- "gpt-4o"
              refresh_every_n_prompts = 3,
              max_refreshes = 3,
            },
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
                i = "<C-D>",
              },
            },
          }
        },
        vectorcode = {
          opts = {
            tool_group = {
              enabled = true,
              -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
              -- if you use @vectorcode_vectorise, it'll be very handy to include
              -- `file_search` here.
              extras = {},
              collapse = false, -- whether the individual tools should be shown in the chat
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
          }
        }
      },
      adapters = {
        http = {
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
                  default = "gpt-5-mini",
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
        }
      },

    })


    vim.keymap.set("n", "<leader>ch", function()
      codecompanion.extensions.history.browse_chats(nil)
    end, { desc = "Open CodeCompanion history picker" })

    vim.keymap.set("n", "`", function()
      codecompanion.toggle()
    end, { desc = "Open CodeCompanion chat buffer" })
  end
}
