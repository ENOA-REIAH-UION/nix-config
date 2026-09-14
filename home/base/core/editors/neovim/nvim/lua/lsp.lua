-- vim.lsp.log.set_level(vim.log.levels.DEBUG)

local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"jsonls",
	"yamlls",
	"tombi",
	"marksman",
	"nil_ls",
	not IS_NIX_ON_DROID and "kotlin_language_server" or nil,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user-lsp-attach", {}),
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set({ "n", "v" }, "<C-CR>", vim.lsp.buf.code_action, opts)

		-- Go to definition / declaration / implementation / references
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

		-- Type definition
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

		-- Rename
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		-- Format
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)

		-- Signature help
		vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help, opts)

		-- Diagnostics
		vim.keymap.set("n", "[e", function()
			vim.diagnostic.jump({
				count = -1,
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)

		vim.keymap.set("n", "]e", function()
			vim.diagnostic.jump({
				count = 1,
				severity = vim.diagnostic.severity.ERROR,
			})
		end, opts)

		-- Previous / next diagnostic (all severities)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1 })
		end, opts)

		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)

		-- Show diagnostic under cursor
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

		-- List diagnostics in current buffer
		vim.keymap.set("n", "<leader>dl", function()
			vim.diagnostic.setloclist()
		end, opts)
	end,
})
