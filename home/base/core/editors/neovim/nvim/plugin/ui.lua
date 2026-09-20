-- ============================================================================
-- Neovim 0.12+
-- Native vim.pack + lazy loading
-- Single file: ~/.config/nvim/init.lua
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function gh(repo)
	return "https://github.com/" .. repo
end

-- ============================================================================
-- Plugins
-- ============================================================================

vim.pack.add({
	{ src = gh("nvim-lualine/lualine.nvim"), name = "lualine.nvim" },
	{ src = gh("catppuccin/nvim"), name = "catppuccin" },

	{ src = gh("nvim-telescope/telescope.nvim"), name = "telescope.nvim" },
	{ src = gh("danielfalk/smart-open.nvim"), name = "smart-open.nvim" },
	{ src = gh("nvim-telescope/telescope-fzy-native.nvim"), name = "telescope-fzy-native.nvim" },

	{ src = gh("mason-org/mason.nvim"), name = "mason.nvim" },
	{ src = gh("neovim/nvim-lspconfig"), name = "nvim-lspconfig" },

	{ src = gh("MagicDuck/grug-far.nvim"), name = "grug-far.nvim" },
	{ src = gh("folke/trouble.nvim"), name = "trouble.nvim" },

	{ src = gh("lewis6991/gitsigns.nvim"), name = "gitsigns.nvim" },
	{ src = gh("RRethy/vim-illuminate"), name = "vim-illuminate" },
	{ src = gh("mikavilpas/yazi.nvim"), name = "yazi.nvim" },

	{ src = gh("nvim-lua/plenary.nvim"), name = "plenary.nvim" },
	{ src = gh("kkharji/sqlite.lua"), name = "sqlite.lua" },
	{ src = gh("nvim-tree/nvim-web-devicons"), name = "nvim-web-devicons" },
}, { load = false })

-- Terminal-first UI:
-- keep Neovim's native messages/input instead of noice/dressing/notify overlays.

-- ============================================================================
-- Lazy loader
-- ============================================================================

local loaded = {}

local function load(name)
	if loaded[name] then
		return
	end

	vim.cmd.packadd(name)
	loaded[name] = true
end

local function load_many(...)
	for _, name in ipairs({ ... }) do
		load(name)
	end
end

-- ============================================================================
-- VeryLazy
-- ============================================================================

vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
		end)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		-- ------------------------------------------------------------------------
		-- lualine
		-- ------------------------------------------------------------------------

		load("lualine.nvim")

		require("lualine").setup({
			options = {
				theme = "catppuccin-nvim",
				component_separators = { left = "│", right = "│" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
				disabled_filetypes = { "TelescopePrompt", "DressingInput", "lazy", "mason" },
			},

			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return " " .. str:upper() .. " "
						end,
						separator = { left = "", right = "" },
						right_padding = 1,
					},
				},

				lualine_b = {
					{
						"branch",
						icon = "",
						separator = { right = "" },
					},
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
					},
					{
						"diagnostics",
						symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
					},
				},

				lualine_c = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = "[No Name]",
							newfile = "[New]",
						},
					},
				},

				lualine_x = {
					{
						"filetype",
						icon_only = false,
					},
					{
						"encoding",
					},
				},

				lualine_y = {
					{
						"progress",
					},
				},

				lualine_z = {
					{
						function()
							local loc = require("lualine.components.location")()
							local sel = require("lualine.components.selectioncount")()

							if sel ~= "" then
								loc = loc .. " (" .. sel .. " sel)"
							end

							return loc
						end,
						separator = { left = "", right = "" },
						left_padding = 1,
						right_padding = 1,
					},
				},
			},

			extensions = { "neo-tree" },
		})
	end,
})

-- ============================================================================
-- Telescope
-- ============================================================================

local telescope_loaded = false

local extra_args = {
	"--hidden",
	"--no-ignore",
	"-g",
	"!.git/",
	"-g",
	"!node_modules/",
	"-g",
	"!.idea/",
	"-g",
	"!pnpm-lock.yaml",
	"-g",
	"!package-lock.json",
	"-g",
	"!go.sum",
	"-g",
	"!lazy-lock.json",
	"-g",
	"!.zsh_history",
}

local function load_telescope()
	if telescope_loaded then
		return
	end

	load_many(
		"plenary.nvim",
		"nvim-web-devicons",
		"telescope-fzy-native.nvim",
		"sqlite.lua",
		"smart-open.nvim",
		"telescope.nvim"
	)

	local telescope = require("telescope")
	local actions = require("telescope.actions")
	local trouble = require("trouble.sources.telescope")

	telescope.setup({
		defaults = {
			scroll_strategy = "limit",
			prompt_prefix = " ",
			selection_caret = " ",
			multi_icon = " ",

			mappings = {
				i = {
					["<C-n>"] = false,
					["<C-u>"] = actions.cycle_history_prev,
					["<C-e>"] = actions.cycle_history_next,
					["<M-u>"] = actions.preview_scrolling_up,
					["<M-e>"] = actions.preview_scrolling_down,
					["<C-h>"] = actions.select_horizontal,
					["<C-t>"] = actions.select_tab,
					["<C-q>"] = trouble.open,
				},

				n = {
					["k"] = false,
					["<S-Tab>"] = false,
					["<Tab>"] = actions.toggle_selection,
					["<BS>"] = actions.delete_buffer,
					["u"] = actions.move_selection_previous,
					["e"] = actions.move_selection_next,

					["U"] = function(prompt_bufnr)
						require("telescope.actions.set").shift_selection(prompt_bufnr, -5)
					end,

					["E"] = function(prompt_bufnr)
						require("telescope.actions.set").shift_selection(prompt_bufnr, 5)
					end,

					["<C-u>"] = actions.cycle_history_prev,
					["<C-e>"] = actions.cycle_history_next,
					["<M-u>"] = actions.preview_scrolling_up,
					["<M-e>"] = actions.preview_scrolling_down,
					["s"] = actions.select_vertical,
					["h"] = actions.select_horizontal,
					["t"] = actions.select_tab,
					["<C-q>"] = trouble.open,
				},
			},

			buffer_previewer_maker = function(filepath, bufnr, opts)
				require("plenary.job")
					:new({
						command = "file",
						args = { "-b", "--mime", filepath },

						on_exit = function(job)
							local result = job:result()

							if result[1] and result[1]:find("charset=binary", 1, true) then
								vim.schedule(function()
									vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
								end)
							else
								require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
							end
						end,
					})
					:sync()
			end,
		},

		pickers = {
			find_files = { previewer = false },
			live_grep = { theme = "ivy" },
			lsp_references = { theme = "ivy" },
			lsp_definitions = { theme = "ivy" },
			lsp_type_definitions = { theme = "ivy" },
			lsp_implementations = { theme = "ivy" },

			lsp_dynamic_workspace_symbols = {
				sorter = telescope.extensions.fzy_native.native_fzy_sorter(),
			},
		},

		extensions = {
			fzy_native = {
				override_generic_sorter = true,
				override_file_sorter = true,
			},

			smart_open = {
				mappings = {
					i = {
						["<C-w>"] = function()
							vim.api.nvim_input("<c-s-w>")
						end,
					},
				},
			},
		},
	})

	telescope.load_extension("fzy_native")
	telescope.load_extension("smart_open")

	telescope_loaded = true
end

-- Telescope keymaps
vim.keymap.set("n", ",a", function()
	load_telescope()
	require("telescope.builtin").buffers()
end)

vim.keymap.set("n", "<leader>;", function()
	load_telescope()
	require("telescope.builtin").command_history()
end)

vim.keymap.set("n", "<leader>e", function()
	load_telescope()
	require("telescope.builtin").find_files()
end)

vim.keymap.set("n", "<leader>E", function()
	load_telescope()
	require("telescope.builtin").find_files({
		find_command = {
			"rg",
			"--color=never",
			"--smart-case",
			"--files",
			unpack(extra_args),
		},
	})
end)

vim.keymap.set("n", "<leader>/", function()
	load_telescope()
	require("telescope.builtin").live_grep()
end)

vim.keymap.set("n", "<leader>?", function()
	load_telescope()
	require("telescope.builtin").live_grep({
		additional_args = extra_args,
	})
end)

vim.keymap.set("n", "<leader>l", function()
	load_telescope()
	require("telescope.builtin").lsp_references({
		initial_mode = "normal",
		reuse_win = true,
	})
end)

vim.keymap.set("n", "<leader>b", function()
	load_telescope()
	require("telescope.builtin").lsp_definitions({
		initial_mode = "normal",
		reuse_win = true,
	})
end)

vim.keymap.set("n", "<leader>m", function()
	load_telescope()
	require("telescope.builtin").lsp_type_definitions({
		initial_mode = "normal",
		reuse_win = true,
	})
end)

vim.keymap.set("n", "<leader>i", function()
	load_telescope()
	require("telescope.builtin").lsp_implementations({
		initial_mode = "normal",
		reuse_win = true,
	})
end)

vim.keymap.set("n", "<leader><leader>", function()
	load_telescope()

	require("telescope").extensions.smart_open.smart_open(require("telescope.themes").get_dropdown({
		cwd_only = true,
		previewer = false,
	}))
end)

-- ============================================================================
-- Mason
-- ============================================================================

local mason_loaded = false

local function load_mason()
	if mason_loaded then
		return
	end

	load("mason.nvim")

	require("mason").setup({
		pip = {
			upgrade_pip = true,
		},

		ui = {
			keymaps = {
				toggle_package_expand = "<Tag>",
				install_package = "k",
				update_all_packages = "K",
				uninstall_package = "x",
				cancel_installation = "<C-c>",
				apply_language_filter = "<C-f>",
				update_package = "<Nop>",
				check_package_version = "<Nop>",
				check_outdated_packages = "<Nop>",
			},
		},
	})

	mason_loaded = true
end

-- Lazy :Mason
vim.api.nvim_create_user_command("Mason", function(opts)
	load_mason()

	vim.cmd({
		cmd = "Mason",
		args = opts.fargs,
		bang = opts.bang,
	})
end, {
	nargs = "*",
	bang = true,
})

-- ============================================================================
-- grug-far
-- Original config has no lazy trigger, so keep it eager.
-- ============================================================================

load("grug-far.nvim")
require("grug-far").setup({})

-- ============================================================================
-- Trouble
-- ============================================================================

local trouble_loaded = false

local function load_trouble()
	if trouble_loaded then
		return
	end

	load_many("nvim-web-devicons", "trouble.nvim")

	require("trouble").setup({
		keys = {
			u = "prev",
			e = "next",
			["<Tab>"] = "jump",
			["<CR>"] = "jump_close",
			s = "jump_split",
			S = "jump_vsplit",
			za = "fold_toggle",
			zr = "fold_open",
			zc = "fold_close",
		},
	})

	trouble_loaded = true
end

vim.api.nvim_create_user_command("Trouble", function(opts)
	load_trouble()

	vim.cmd({
		cmd = "Trouble",
		args = opts.fargs,
		bang = opts.bang,
	})
end, {
	nargs = "*",
	bang = true,
})

vim.keymap.set("n", ",e", function()
	load_trouble()
	vim.cmd("Trouble diagnostics toggle")
end, { silent = true })

vim.keymap.set("n", ",E", function()
	load_trouble()
	vim.cmd("Trouble diagnostics toggle filter.buf=0")
end, { silent = true })

vim.keymap.set("n", ",q", function()
	load_trouble()
	vim.cmd("Trouble qflist toggle")
end, { silent = true })

vim.keymap.set("n", "[q", function()
	load_trouble()

	local trouble = require("trouble")

	if trouble.is_open() then
		trouble.previous({ skip_groups = true, jump = true })
	else
		vim.cmd.cprev()
	end
end)

vim.keymap.set("n", "]q", function()
	load_trouble()

	local trouble = require("trouble")

	if trouble.is_open() then
		trouble.next({ skip_groups = true, jump = true })
	else
		vim.cmd.cnext()
	end
end)

-- ============================================================================
-- Gitsigns
-- ============================================================================

local gitsigns_loaded = false

local function load_gitsigns()
	if gitsigns_loaded then
		return
	end

	load("gitsigns.nvim")

	require("gitsigns").setup({
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},

		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			local opts = { buffer = bufnr }

			vim.keymap.set({ "n", "v" }, "<leader>gs", gs.stage_hunk, opts)
			vim.keymap.set("n", "<leader>gS", gs.stage_buffer, opts)
			vim.keymap.set("n", "<leader>gl", gs.undo_stage_hunk, opts)
			vim.keymap.set({ "n", "v" }, "<leader>gr", gs.reset_hunk, opts)
			vim.keymap.set("n", "<leader>gR", gs.reset_buffer, opts)
			vim.keymap.set("n", "<leader>gp", gs.preview_hunk, opts)

			vim.keymap.set("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, opts)

			vim.keymap.set("n", "<leader>gd", gs.diffthis, opts)

			vim.keymap.set("n", "<leader>gD", function()
				gs.diffthis("~")
			end, opts)

			local expr_opts = { expr = true, buffer = bufnr }

			vim.keymap.set("n", "[[", function()
				if vim.wo.diff then
					return "[["
				end

				vim.schedule(function()
					gs.prev_hunk()
				end)

				return "<Ignore>"
			end, expr_opts)

			vim.keymap.set("n", "]]", function()
				if vim.wo.diff then
					return "]]"
				end

				vim.schedule(function()
					gs.next_hunk()
				end)

				return "<Ignore>"
			end, expr_opts)
		end,
	})

	gitsigns_loaded = true
end

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	callback = load_gitsigns,
})

-- ============================================================================
-- Illuminate
-- ============================================================================

local illuminate_loaded = false

local function load_illuminate()
	if illuminate_loaded then
		return
	end

	load("vim-illuminate")

	local illuminate = require("illuminate")

	illuminate.configure({
		providers = { "lsp", "treesitter", "regex" },
		delay = 200,

		filetypes_denylist = {
			"TelescopePrompt",
			"Trouble",
			"neo-tree",
			"neo-tree-popup",
			"DressingInput",
			"spectre_panel",
			"Outline",
			"checkhealth",
		},

		min_count_to_highlight = 2,
	})

	local function map(buffer)
		vim.keymap.set("n", "_", function()
			illuminate.goto_next_reference(false)
		end, { buffer = buffer })

		vim.keymap.set("n", "+", function()
			illuminate.goto_prev_reference(false)
		end, { buffer = buffer })
	end

	map(nil)

	vim.api.nvim_create_autocmd("FileType", {
		callback = function()
			map(vim.api.nvim_get_current_buf())
		end,
	})

	illuminate_loaded = true
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = load_illuminate,
})

-- ============================================================================
-- Yazi
-- ============================================================================

local yazi_loaded = false

local function load_yazi()
	if yazi_loaded then
		return
	end

	load("yazi.nvim")

	require("yazi").setup({
		keymaps = {
			show_help = "~",
		},
	})

	yazi_loaded = true
end

vim.keymap.set("n", "<leader>y", function()
	load_yazi()
	vim.cmd("Yazi")
end, { silent = true })
