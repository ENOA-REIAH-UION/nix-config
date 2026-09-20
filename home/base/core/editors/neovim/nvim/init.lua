-- init.lua

IS_NIX_ON_DROID = vim.fn.isdirectory(vim.fn.expand("~/.config/nix-on-droid")) == 1

require("options")
require("keymaps")
require("lsp")
