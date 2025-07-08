return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "copilot",
    rag_service = {                             -- RAG Service configuration
      enabled = true,                           -- Enables the RAG service
      host_mount = os.getenv("HOME"),           -- Host mount path for the rag service (Docker will mount this path)
      runner = "docker",                        -- Runner for the RAG service (can use docker or nix)
      llm = {                                   -- Language Model (LLM) configuration for RAG service
        provider = "openai",                    -- LLM provider
        endpoint = "https://api.openai.com/v1", -- LLM API endpoint
        api_key = "OPENAI_API_KEY",             -- Environment variable name for the LLM API key
        model = "gpt-4o-mini",                  -- LLM model name
        extra = nil,                            -- Additional configuration options for LLM
      },
      embed = {                                 -- Embedding model configuration for RAG service
        provider = "openai",                    -- Embedding provider
        endpoint = "https://api.openai.com/v1", -- Embedding API endpoint
        api_key = "OPENAI_API_KEY",             -- Environment variable name for the embedding API key
        model = "text-embedding-3-large",       -- Embedding model name
        extra = nil,                            -- Additional configuration options for the embedding model
      },
      docker_extra_args = "",                   -- Extra arguments to pass to the docker command
    },
    -- add any opts here
    -- for example
    -- providers = {
    --   openai = {
    --     endpoint = "https://api.openai.com/v1",
    --     model = "gpt-4o",               -- your desired model (or use gpt-4o, etc.)
    --     extra_request_body = {
    --       timeout = 30000,              -- Timeout in milliseconds, increase this for reasoning models
    --       temperature = 0.75,
    --       max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
    --       --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
    --     },
    --   },
    -- },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick",         -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
    "stevearc/dressing.nvim",        -- for input provider dressing
    "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
    -- "zbirenbaum/copilot.lua",        -- for providers='copilot'
    "github/copilot.vim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
