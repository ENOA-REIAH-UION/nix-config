-- ~/.config/nvim/lua/plugins/colorscheme.lua

local active_colorscheme = "kanagawa"

local themes = {
	kanagawa = {
		src = "https://github.com/rebelot/kanagawa.nvim",
		config = function()
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
						-- =====================================================
						-- Diagnostics
						-- =====================================================
						DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
						DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
						DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
						DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),

						-- =====================================================
						-- Telescope
						-- =====================================================
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

						-- =====================================================
						-- Floating windows
						-- =====================================================
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },

						NormalDark = {
							fg = theme.ui.fg_dim,
							bg = theme.ui.bg_m3,
						},

						-- =====================================================
						-- Lazy / Mason
						-- =====================================================
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
		end,
	},

	tokyonight = {
		src = "https://github.com/folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				transparent = true,
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
			})
		end,
	},

	catppuccin = {
		src = "https://github.com/catppuccin/nvim",
		config = function()
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
					indent_blankline = { enabled = true },
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
		end,
	},

	["monokai-pro"] = {
		src = "https://github.com/loctvl842/monokai-pro.nvim",
		config = function()
			require("monokai-pro").setup({
				transparent_background = false,
				terminal_colors = true,
				devicons = true,
				styles = {
					comment = { italic = false },
					keyword = { italic = false },
					type = { italic = false },
					storageclass = { italic = false },
					structure = { italic = false },
					parameter = { italic = false },
					annotation = { italic = false },
					tag_attribute = { italic = false },
				},
				filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
				day_night = {
					enable = false,
					day_filter = "pro",
					night_filter = "spectrum",
				},
				inc_search = "background", -- underline | background
				background_clear = {
					"toggleterm",
					"telescope",
					"renamer",
					"notify",
				},
				plugins = {
					bufferline = {
						underline_selected = false,
						underline_visible = false,
						underline_fill = false,
						bold = true,
					},
					indent_blankline = {
						context_highlight = "default", -- default | pro
						context_start_underline = false,
					},
				},
				override = function(scheme)
					return {}
				end,
				override_palette = function(filter)
					return {}
				end,
				override_scheme = function(scheme, palette, colors)
					return {}
				end,
			})
		end,
	},
}

local function apply_colorscheme(name)
	local theme = themes[name]

	if not theme then
		vim.notify(
			("未知配色方案: %s，可用: %s"):format(
				name,
				table.concat(vim.tbl_keys(themes), ", ")
			),
			vim.log.levels.ERROR
		)
		return
	end

	-- 只安装当前启用的主题插件，避免安装无关插件
	vim.pack.add({
		{ src = theme.src },
	})

	if theme.config then
		theme.config()
	end

	vim.cmd.colorscheme(name)
end

apply_colorscheme(active_colorscheme)
