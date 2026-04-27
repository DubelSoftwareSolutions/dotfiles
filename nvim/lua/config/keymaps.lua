-- Kitty word deletion
vim.keymap.set("i", "<C-w>", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })

-- Forward word deletion
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { noremap = true })
