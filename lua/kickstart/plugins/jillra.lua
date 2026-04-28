return {
  -- use a local directory for development
  dir = "/home/neo/personal/learn/plugins/jillra",
  name = "jillra",
  config = function()
    require("jillra").setup()
-- lua print(require("jillra").hello())
  end
}
