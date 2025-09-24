return {
  'ckolkey/ts-node-action',
  config = function()
    require('ts-node-action').setup({})
    vim.keymap.set(
      { "n" },
      "K",
      require("ts-node-action").node_action,
      { desc = "Trigger Node Action" }
    )
  end
}
