return {
    "ravitemer/mcphub.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
        require("mcphub").setup({
            port = 37373,
            server_url = nil,
            workspace = {
                enabled = true,
                port_range = { min = 40000, max = 41000 },
            },
        })
    end
}
