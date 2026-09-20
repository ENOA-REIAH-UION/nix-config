return {
	cmd = { "lua-language-server" },

	filetypes = {
		"lua",
	},

	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".git",
	},

	settings = {
		Lua = {
			completion = {
				postfix = ".",
			},

			diagnostics = {
				disable = {
					"lowercase-global",
				},
				globals = {
					"vim",
				},
			},

			format = {
				enable = true,
				defaultConfig = {
					["stylua"] = {
						command = "stylua",
					},
				},
			},

			workspace = {
				checkThirdParty = false,
				ignoreDir = {
					".vscode",
					"node_modules",
				},
			},

			runtime = {
				version = "LuaJIT",
			},

			telemetry = {
				enable = false,
			},
		},
	},
}
