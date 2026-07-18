-- Kitty word deletion
vim.keymap.set("i", "<C-w>", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })

-- Forward word deletion
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { noremap = true })

-- Newline
vim.keymap.set("n", "<leader>o", "<cmd>put = ''<CR>", { noremap = true })
vim.keymap.set("n", "<leader>O", "<cmd>put! = ''<CR>", { noremap = true })
