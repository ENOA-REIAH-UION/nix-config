-- ~/.config/nvim/lua/plugins/colorscheme.lua

-- ============================================================================
-- Kanagawa
-- ============================================================================

vim.pack.add({
	{
		src = "https://github.com/rebelot/kanagawa.nvim",
	},
})

local kanagawa_enabled = true

if kanagawa_enabled then
	require("kanagawa").setup({
		commentStyle = { italic = false },
		functionStyle = { bold = true },
		keywordStyle = { italic = false },
		statementStyle = { bold = true },
		typeStyle = { bold = true },
		variablebuiltinStyle = { italic = false },

		theme = "wave",

		background = {
			dark = "wave",
			light = "lotus",
		},

		colors = {
			theme = {
				all = {
					ui = {
						bg_gutter = "none",
					},
				},
			},
		},

		overrides = function(colors)
			local theme = colors.theme

			local makeDiagnosticColor = function(color)
				local c = require("kanagawa.lib.color")
				return {
					fg = color,
					bg = c(color):blend(theme.ui.bg, 0.95):to_hex(),
				}
			end

			return {
				-- =================================================================
				-- Diagnostics
				-- =================================================================

				DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
				DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
				DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
				DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),

				-- =================================================================
				-- Telescope
				-- =================================================================

				TelescopeTitle = {
					fg = theme.ui.special,
					bold = true,
				},

				TelescopePromptNormal = {
					bg = theme.ui.bg_p1,
				},

				TelescopePromptBorder = {
					fg = theme.ui.bg_p1,
					bg = theme.ui.bg_p1,
				},

				TelescopeResultsNormal = {
					fg = theme.ui.fg_dim,
					bg = theme.ui.bg_m1,
				},

				TelescopeResultsBorder = {
					fg = theme.ui.bg_m1,
					bg = theme.ui.bg_m1,
				},

				TelescopePreviewNormal = {
					bg = theme.ui.bg_dim,
				},

				TelescopePreviewBorder = {
					bg = theme.ui.bg_dim,
					fg = theme.ui.bg_dim,
				},

				-- =================================================================
				-- Floating windows
				-- =================================================================

				NormalFloat = {
					bg = "none",
				},

				FloatBorder = {
					bg = "none",
				},

				FloatTitle = {
					bg = "none",
				},

				-- Dark floating/window background
				NormalDark = {
					fg = theme.ui.fg_dim,
					bg = theme.ui.bg_m3,
				},

				-- =================================================================
				-- Lazy / Mason
				-- =================================================================

				LazyNormal = {
					bg = theme.ui.bg_m3,
					fg = theme.ui.fg_dim,
				},

				MasonNormal = {
					bg = theme.ui.bg_m3,
					fg = theme.ui.fg_dim,
				},
			}
		end,
	})

	vim.cmd.colorscheme("kanagawa")
end

-- ============================================================================
-- TokyoNight
-- ============================================================================

vim.pack.add({
	{
		src = "https://github.com/folke/tokyonight.nvim",
	},
})

local tokyonight_enabled = false

if tokyonight_enabled then
	require("tokyonight").setup({
		transparent = true,

		styles = {
			sidebars = "transparent",
			floats = "transparent",
		},
	})

	vim.cmd.colorscheme("tokyonight")
end

-- ============================================================================
-- Catppuccin
-- ============================================================================

vim.pack.add({
	{
		src = "https://github.com/catppuccin/nvim",
	},
})

local catppuccin_enabled = false

if catppuccin_enabled then
	require("catppuccin").setup({
		flavour = "auto",

		background = {
			light = "latte",
			dark = "macchiato",
		},

		transparent_background = true,

		float = {
			transparent = true,
			solid = true,
		},

		term_colors = true,

		custom_highlights = function(C)
			local O = require("catppuccin").options

			return {
				["@module"] = {
					fg = C.lavender,
					style = O.styles.miscs or { "italic" },
				},

				["@type.builtin"] = {
					fg = C.yellow,
					style = O.styles.properties or { "italic" },
				},
			}
		end,

		lsp_styles = {
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},

		integrations = {
			bufferline = false,
			cmp = true,
			diffview = true,
			fidget = true,
			gitsigns = true,
			illuminate = true,
			indent_blankline = {
				enabled = true,
			},
			lsp_trouble = true,
			mason = true,
			neotree = true,
			noice = true,
			notify = true,
			rainbow_delimiters = true,
			telescope = true,
			treesitter_context = true,
		},
	})

	vim.cmd.colorscheme("catppuccin")
end
