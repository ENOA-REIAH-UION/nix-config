return {
	cmd = { "pyright-langserver", "--stdio" },

	filetypes = {
		"python",
	},

	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},

	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",

				diagnosticSeverityOverrides = {
					reportMissingImports = "error",
					reportUndefinedVariable = "none",
				},
			},
		},
	},
}
