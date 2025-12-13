return {
  "dmtrKovalenko/fff.nvim",
  -- grabs a prebuilt binary when available, otherwise builds from Rust toolchain
  build = function() require("fff.download").download_or_build_binary() end,

  lazy = false,
  keys = {
    { "<leader>sf", function() require("fff").find_files() end, desc = "Files (fff)" },
  },

  config = function()
    require('fff').setup({
      preview = { enabled = false },
      lazy_sync = true,
      layout = {
        height = 0.4,
        width = 0.4,
        prompt_position = 'bottom', -- or 'top'
        preview_position = 'top',   -- or 'left', 'right', 'top', 'bottom'
        preview_size = 0.5,
      },
    })
  end
}
