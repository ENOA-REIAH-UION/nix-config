vim.pack.add({
	{
		src = "https://github.com/lukas-reineke/indent-blankline.nvim",
		name = "indent-blankline.nvim",
	},
	{
		src = "https://github.com/folke/snacks.nvim",
		name = "snacks.nvim",
	},
})

require("ibl").setup({
	indent = {
		char = "│",
		tab_char = "┆",
	},
})

require("snacks").setup({
	indent = {
		enabled = false,
	},
})
