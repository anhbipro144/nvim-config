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
	{
		"rebelot/kanagawa.nvim",
		config = function()

			local kanagawa_opts = {
				theme = "wave",
				transparent = true,
				colors = {
					theme = {
						all = { ui = { bg_gutter = "none" } },
					},
				},
				overrides = function(_)
					return {
						-- gutter pieces
						SignColumn   = { bg = "NONE" },
						LineNr       = { bg = "NONE" },
						CursorLineNr = { bg = "NONE" },
						FoldColumn   = { bg = "NONE" },

						-- statusline
						StatusLine   = { bg = "NONE" },
						StatusLineNC = { bg = "NONE" },

						-- keep window borders visible without a blocky bg
						WinSeparator = { bg = "NONE" },
					}
				end,
			}
			require('kanagawa').setup(kanagawa_opts)

			-- setup must be called before loading
			vim.cmd("colorscheme kanagawa")


			vim.keymap.set("n", "<leader>uu", function()
				kanagawa_opts.transparent = not kanagawa_opts.transparent
				require('kanagawa').setup(kanagawa_opts)
				vim.cmd("colorscheme kanagawa")
			end, { desc = "Toggle Kanagawa transparency" })

			local function make_telescope_transparent()
				vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
				vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })

				-- local groups = {
				-- 	"NormalFloat", "FloatBorder",
				-- 	"TelescopeNormal", "TelescopeBorder",
				-- 	"TelescopePromptNormal", "TelescopePromptBorder",
				-- 	"TelescopeResultsNormal", "TelescopeResultsBorder",
				-- 	"TelescopePreviewNormal", "TelescopePreviewBorder",
				-- }
				local groups = {
					"TelescopeNormal", "TelescopeBorder", "TelescopeTitle",
					"TelescopePromptNormal", "TelescopePromptBorder", "TelescopePromptTitle",
					"TelescopeResultsNormal", "TelescopeResultsBorder", "TelescopeResultsTitle",
					"TelescopePreviewNormal", "TelescopePreviewBorder", "TelescopePreviewTitle",
				}
				for _, g in ipairs(groups) do vim.api.nvim_set_hl(0, g, { bg = "NONE" }) end
			end

			make_telescope_transparent()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = make_telescope_transparent,
			})
		end
	},
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
	-- {
	-- 	"catppuccin/nvim",
	-- 	name = "catppuccin",
	-- 	priority = 1000,
	--
	-- 	config = function()
	-- 		require("catppuccin").setup({
	-- 			flavour = "mocha", -- latte, frappe, macchiato, mocha
	-- 			transparent_background = true,
	-- 			integrations = { blink_cmp = true },
	-- 		})
	--
	--
	-- 		vim.cmd.colorscheme "catppuccin"
	--
	--
	-- 		vim.keymap.set("n", "<leader>uu", function()
	-- 			local cat = require("catppuccin")
	-- 			cat.options.transparent_background = not cat.options.transparent_background
	-- 			cat.compile()
	-- 			vim.cmd.colorscheme(vim.g.colors_name)
	-- 		end, { desc = "Toggle Catppuccin transparency" })
	--
	-- 		local function make_telescope_transparent()
	-- 			local groups = {
	-- 				"NormalFloat", "FloatBorder",
	-- 				"TelescopeNormal", "TelescopeBorder",
	-- 				"TelescopePromptNormal", "TelescopePromptBorder",
	-- 				"TelescopeResultsNormal", "TelescopeResultsBorder",
	-- 				"TelescopePreviewNormal", "TelescopePreviewBorder",
	-- 			}
	-- 			for _, g in ipairs(groups) do
	-- 				vim.api.nvim_set_hl(0, g, { bg = "NONE" })
	-- 			end
	-- 		end
	--
	-- 		make_telescope_transparent()
	-- 		vim.api.nvim_create_autocmd("ColorScheme", {
	-- 			callback = make_telescope_transparent,
	-- 		})
	-- 	end
	-- }

}
