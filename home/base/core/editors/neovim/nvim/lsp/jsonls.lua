return {
	cmd = {
		"vscode-json-language-server",
		"--stdio",
	},

	filetypes = {
		"json",
		"jsonc",
		"json5",
	},

	root_markers = {
		"package.json",
		".git",
	},

	settings = {
		json = {
			validate = {
				enable = true,
			},

			-- schemas = require("schemastore").json.schemas(),
		},
	},
}
