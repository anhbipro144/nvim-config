return {
	{
		"sainnhe/sonokai",
		priority = 1000,
		config = function()
			vim.g.sonokai_transparent_background = "1"
			vim.g.sonokai_enable_italic = "1"
			vim.g.sonokai_style = "andromeda"
			vim.cmd.colorscheme("sonokai")
		end,
	},
	-- {
	--
	--
	-- 	"rose-pine/neovim",
	-- 	name = "rose-pine",
	-- 	priority = 1000,
	-- 	config = function ()
	-- 		require("rose-pine").setup({
	-- 			styles = {
	-- 				transparency = true,
	-- 			}
	-- 		})
	--
	-- 		vim.cmd.colorscheme("rose-pine");
	-- 	end
	--
	-- }
	-- {
	-- 	"loctvl842/monokai-pro.nvim",
	-- 	config = function()
	-- 		require("monokai-pro").setup({
	-- 			transparent_background = true,
	-- 			background_clear = {
	-- 				"neo-tree",
	-- 				"telescope",
	-- 				"bufferline"
	-- 			},
	-- 		})
	-- 		vim.cmd.colorscheme("monokai-pro");
	-- 	end
	-- }

}
