return {
  "Davidyz/VectorCode",
  version = "*",
  -- build = "pipx upgrade vectorcode",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("vectorcode").setup(
      {
        --     chunk_mode = true,
        --     chunk_size = 2500,     -- number of tokens per request
        async_backend = "lsp", -- or "lsp"
      }


    )
  end
}
