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

local telescope_loaded = false

local extra_args = {
  "--hidden",
  "--no-ignore",
  "--glob", "!.git/",
  "--glob", "!node_modules/",
  "--glob", "!.idea/",
  "--glob", "!package-lock.json",
  "--glob", "!yarn.lock",
  "--glob", "!pnpm-lock.yaml",
  "--glob", "!.zsh_history",
}

local function load_telescope()
  if telescope_loaded then
    return
  end

  telescope_loaded = true

  load_many(
    "plenary.nvim",
    "nvim-web-devicons",
    "telescope-fzy-native.nvim",
    "telescope.nvim"
  )

  local telescope = require("telescope")

  telescope.setup({
    defaults = {
      file_ignore_patterns = {
        "%.git/",
        "node_modules/",
        "%.idea/",
        "package%-lock%.json",
        "yarn%.lock",
        "pnpm%-lock%.yaml",
        "%.zsh_history",
      },

      mappings = {
        i = {
          ["<C-u>"] = "cycle_history_next",
          ["<C-e>"] = "cycle_history_prev",

          ["<A-u>"] = "preview_scrolling_up",
          ["<A-e>"] = "preview_scrolling_down",

          ["<C-h>"] = "which_key",
          ["<C-t>"] = "select_tab",
          ["<C-q>"] = "smart_send_to_qflist",
        },

        n = {
          ["k"] = false,
          ["<S-Tab>"] = false,

          ["<Tab>"] = "toggle_selection",
          ["<BS>"] = "delete_buffer",

          ["u"] = "move_selection_previous",
          ["e"] = "move_selection_next",

          ["U"] = function(prompt_bufnr)
            for _ = 1, 5 do
              require("telescope.actions").move_selection_previous(prompt_bufnr)
            end
          end,

          ["E"] = function(prompt_bufnr)
            for _ = 1, 5 do
              require("telescope.actions").move_selection_next(prompt_bufnr)
            end
          end,

          ["<C-u>"] = "cycle_history_next",
          ["<C-e>"] = "cycle_history_prev",

          ["<A-u>"] = "preview_scrolling_up",
          ["<A-e>"] = "preview_scrolling_down",

          ["s"] = "select_vertical",
          ["h"] = "select_horizontal",
          ["t"] = "select_tab",

          ["<C-q>"] = "smart_send_to_qflist",
        },
      },
    },

    pickers = {
      find_files = {
        hidden = true,
        previewer = false,
      },

      live_grep = {
        additional_args = function()
          return extra_args
        end,
      },

      grep_string = {
        additional_args = function()
          return extra_args
        end,
      },

      buffers = {
        sort_lastused = true,
        ignore_current_buffer = false,
      },
    },

    extensions = {
      fzy_native = {
        override_generic_sorter = true,
        override_file_sorter = true,
      },
    },
  })

  telescope.load_extension("fzy_native")
end

local function telescope_builtin(name, opts)
  load_telescope()
  require("telescope.builtin")[name](opts)
end

vim.keymap.set("n", "<leader><leader>", function()
  local cwd = vim.fn.expand("%:p:h")
  if cwd == "" then
    cwd = vim.fn.getcwd()
  end
  telescope_builtin("find_files", {
    cwd = cwd,
  })
end, { desc = "Find Files (buffer dir)" })

vim.keymap.set("n", "<leader>,", function()
  telescope_builtin("buffers")
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>fb", function()
  telescope_builtin("buffers")
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>fB", function()
  telescope_builtin("buffers", {
    sort_lastused = true,
  })
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>ff", function()
  telescope_builtin("find_files", {
    cwd = vim.fn.getcwd(),
  })
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>fc", function()
  telescope_builtin("find_files", {
    cwd = vim.fn.stdpath("config"),
  })
end, { desc = "Config Files" })

vim.keymap.set("n", "<leader>fr", function()
  telescope_builtin("oldfiles")
end, { desc = "Recent Files" })

vim.keymap.set("n", "<leader>fR", function()
  telescope_builtin("oldfiles", {
    cwd_only = true,
  })
end, { desc = "Recent Files (cwd)" })

vim.keymap.set("n", "<leader>fg", function()
  telescope_builtin("git_files")
end, { desc = "Git Files" })

vim.keymap.set("n", "<leader>sg", function()
  telescope_builtin("live_grep")
end, { desc = "Live Grep" })

vim.keymap.set("n", "<leader>sw", function()
  telescope_builtin("grep_string")
end, { desc = "Word Search" })

vim.keymap.set("n", "<leader>sq", function()
  telescope_builtin("quickfix")
end, { desc = "Quickfix" })

vim.keymap.set("n", "<leader>sh", function()
  telescope_builtin("help_tags")
end, { desc = "Help" })

vim.keymap.set("n", "<leader>sk", function()
  telescope_builtin("keymaps")
end, { desc = "Keymaps" })

vim.keymap.set("n", "<leader>sc", function()
  telescope_builtin("command_history")
end, { desc = "Command History" })

vim.keymap.set("n", "<leader>sC", function()
  telescope_builtin("commands")
end, { desc = "Commands" })

vim.keymap.set("n", "<leader>sd", function()
  telescope_builtin("diagnostics")
end, { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>ss", function()
  telescope_builtin("lsp_document_symbols")
end, { desc = "Document Symbols" })

vim.keymap.set("n", "<leader>sS", function()
  telescope_builtin("lsp_dynamic_workspace_symbols")
end, { desc = "Workspace Symbols" })

vim.keymap.set("n", "<leader>l", function()
  telescope_builtin("lsp_references")
end, { desc = "LSP References" })

vim.keymap.set("n", "<leader>b", function()
  telescope_builtin("lsp_definitions")
end, { desc = "LSP Definitions" })

vim.keymap.set("n", "<leader>m", function()
  telescope_builtin("lsp_type_definitions")
end, { desc = "LSP Type Definitions" })

vim.keymap.set("n", "<leader>i", function()
  telescope_builtin("lsp_implementations")
end, { desc = "LSP Implementations" })

vim.keymap.set("n", "<leader>gc", function()
  telescope_builtin("git_commits")
end, { desc = "Git Commits" })

vim.keymap.set("n", "<leader>gs", function()
  telescope_builtin("git_status")
end, { desc = "Git Status" })

vim.keymap.set("n", "<leader>gS", function()
  telescope_builtin("git_stash")
end, { desc = "Git Stash" })

vim.keymap.set("n", ",a", function()
  telescope_builtin("buffers")
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>;", function()
  telescope_builtin("command_history")
end, { desc = "Command History" })

vim.keymap.set("n", "<leader>e", function()
  telescope_builtin("find_files", {
    cwd = vim.fn.getcwd(),
  })
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>E", function()
  load_telescope()

  require("telescope.builtin").find_files({
    cwd = vim.fn.getcwd(),
    find_command = vim.list_extend(
      { "rg", "--files" },
      extra_args
    ),
  })
end, { desc = "Find Files (all)" })

vim.keymap.set("n", "<leader>/", function()
  telescope_builtin("live_grep")
end, { desc = "Live Grep" })

vim.keymap.set("n", "<leader>?", function()
  load_telescope()

  require("telescope.builtin").live_grep({
    additional_args = function()
      return extra_args
    end,
  })
end, { desc = "Live Grep (all)" })

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
