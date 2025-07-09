return {
  "Davidyz/VectorCode",
  version = "*",
  -- build = "pipx upgrade vectorcode",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("vectorcode").setup({
      -- When using via CodeCompanion or LSP extension, enable chunked requests
      chunk_mode = true,
      -- Optionally adjust chunk size (default is often fine)
      chunk_size = 512, -- number of tokens per request
    })
  end
}
