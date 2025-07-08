return {
	-- {
	-- 	"sainnhe/sonokai",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.g.sonokai_transparent_background = "1"
	-- 		vim.g.sonokai_enable_italic = "1"
	-- 		vim.g.sonokai_style = "andromeda"
	-- 		vim.cmd.colorscheme("sonokai")
	-- 	end,
	-- },
	-- {
	-- 	"catppuccin/nvim",
	-- 	as = "catppuccin",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("catppuccin").setup()
	--
	-- 		-- setup must be called before loading
	-- 		-- vim.cmd.colorscheme "catppuccin"
	-- 		vim.cmd.colorscheme("catppuccin");
	-- 	end
	-- },
	--
	-- {
	-- 	"rebelot/kanagawa.nvim",
	-- 	config = function()
	-- 		require('kanagawa').setup({
	-- 			globalStatus = true,
	-- 			compile = true, -- enable compiling the colorscheme
	-- 			undercurl = true, -- enable undercurls
	-- 			-- commentStyle = { italic = true },
	-- 			-- keywordStyle = { italic = true },
	-- 			-- statementStyle = { bold = true },
	-- 			transparent = true, -- do not set background color
	-- 			-- dimInactive = true, -- dim inactive window `:h hl-NormalNC`
	-- 			-- terminalColors = true, -- define vim.g.terminal_color_{0,17}
	-- 			colors = { -- add/modify theme and palette colors
	-- 				theme = {
	-- 					all = {
	-- 						ui = {
	-- 							bg_gutter = "none",
	-- 						}
	-- 					}
	-- 				},
	-- 			},
	-- 			overrides = function(colors)
	-- 				local theme = colors.theme
	-- 				return {
	-- 					NormalFloat = { bg = "none", fg = "none", },
	-- 					FloatBorder = { bg = "none", fg = "none" },
	-- 					FloatTitle = { bg = "none", fg = "none" },
	-- 					-- Pmenu = { blend = vim.o.pumblend },
	--
	--
	--
	--
	--
	-- 					-- Save an hlgroup with dark background and dimmed foreground
	-- 					-- so that you can use it where your still want darker windows.
	-- 					-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
	-- 					NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
	--
	-- 					-- Popular plugins that open floats will link to NormalFloat by default;
	-- 					-- set their background accordingly if you wish to keep them dark and borderless
	-- 					LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
	-- 					MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
	--
	-- 					TelescopeTitle = { fg = theme.ui.special, bold = true },
	-- 					TelescopePromptNormal = { bg = theme.ui.bg_p1 },
	-- 					TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
	-- 					TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
	-- 					TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
	-- 					TelescopePreviewNormal = { bg = theme.ui.bg_dim },
	-- 					TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
	-- 				}
	-- 			end,
	-- 			theme = "wave", -- Load "wave" theme when 'background' option is not set
	-- 			background = { -- map the value of 'background' option to a theme
	-- 				dark = "dragon", -- try "dragon" !
	-- 				light = "lotus"
	-- 			},
	-- 		})
	--
	--
	-- 		vim.cmd.colorscheme("kanagawa")
	-- 	end
	-- },
	-- {
	-- 	"rose-pine/neovim",
	-- 	name = "rose-pine",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("rose-pine").setup({
	-- 			styles = {
	-- 				transparency = true,
	-- 			}
	-- 		})
	--
	-- 		vim.cmd.colorscheme("rose-pine");
	-- 	end
	--
	-- },
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
	-- },
	--
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {},
	-- 	config = function()
	-- 		require("tokyonight").setup({
	-- 			transparent = true,
	--
	-- 		})
	-- 		vim.cmd.colorscheme("tokyonight");
	-- 	end
	-- },
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,

		config = function()
			require("catppuccin").setup({
				flavour = "frappe", -- latte, frappe, macchiato, mocha
				transparent_background = true, -- disables setting the background color.
				integrations = { blink_cmp = true },
			})


			vim.cmd.colorscheme "catppuccin"
		end
	}

}
