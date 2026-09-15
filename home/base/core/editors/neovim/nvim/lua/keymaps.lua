-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("", "<Space>", "<Nop>")

-- special keys
vim.keymap.set({ "n", "v" }, ";", ":")
vim.keymap.set("", "<Tab>", "<Nop>") -- Will be handled in `plugins/completion.lua`

-- reserved keys
vim.keymap.set("", "s", "<Nop>")
vim.keymap.set("", "S", "<Nop>")

-- up, down, left, right
vim.keymap.set("", "K", "5k")
vim.keymap.set("", "J", "5j")

vim.keymap.set("n", "<C-k>", 'line(".")>1 ? ":m .-2<CR>" : ""', { expr = true, silent = true })
vim.keymap.set("n", "<C-j>", 'line(".")<line("$") ? ":m .+1<CR>" : ""', { expr = true, silent = true })
vim.keymap.set("v", "<C-k>", 'line(".")>1 ? ":m \'<-2<CR>gv" : ""', { expr = true, silent = true })
vim.keymap.set("v", "<C-j>", 'line(".")<line("$") ? ":m \'>+1<CR>gv" : ""', { expr = true, silent = true })

vim.keymap.set("c", "<C-k>", "<Up>")
vim.keymap.set("c", "<C-j>", "<Down>")

-- redo, undo
vim.keymap.set("n", "U", "<C-r>")

-- yank, paste
vim.keymap.set("x", "p", '"_dP')
vim.keymap.set("x", "P", '"_dp')

vim.keymap.set({ "n", "v" }, "x", '"_x')

vim.keymap.set("n", "dw", 'vb"_d')
vim.keymap.set("n", "cw", 'vb"_c')

-- search keys
-- vim.keymap.set("n", "-", "'Nn'[v:searchforward]", { expr = true })
-- vim.keymap.set("x", "-", "'Nn'[v:searchforward]", { expr = true })
-- vim.keymap.set("o", "-", "'Nn'[v:searchforward]", { expr = true })
-- vim.keymap.set("n", "=", "'nN'[v:searchforward]", { expr = true })
-- vim.keymap.set("x", "=", "'nN'[v:searchforward]", { expr = true })
-- vim.keymap.set("o", "=", "'nN'[v:searchforward]", { expr = true })

-- vim.keymap.set("v", "-", function() require("utils").search(false) end)
-- vim.keymap.set("v", "=", function() require("utils").search(true) end)

-- tab management
vim.keymap.set({ "n", "v" }, "tt", ":tabedit<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "tT", ":tab split<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "tn", ":-tabnext<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "ti", ":+tabnext<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "tN", ":-tabmove<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "tI", ":+tabmove<CR>", { silent = true })

-- other keys
vim.keymap.set("n", "<leader>w", "<Cmd>silent! w<CR>:redraw<CR>")
vim.keymap.set("n", "<leader>q", "<Cmd>confirm q<CR>")
vim.keymap.set("n", "<leader>Q", "<Cmd>confirm qall<CR>")

vim.keymap.set("", "<C-a>", "ggVG$")
vim.keymap.set({ "i", "v" }, "<C-a>", "<Esc>ggVG$")

vim.keymap.set("", "<C-r>", ":filetype detect<CR>", { silent = true })
vim.keymap.set("i", "<C-r>", "<Esc>:filetype detect<CR>a", { silent = true })
