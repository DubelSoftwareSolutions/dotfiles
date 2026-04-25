-- Fix Ctrl+Backspace (which Kitty sends as hex 0x17 / Ctrl+W)
vim.keymap.set("i", "<C-w>", "<C-w>", { noremap = true }) 
-- In some cases, Neovim sees hex 0x17 as a literal character; this forces it:
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })

-- Fix Ctrl+Delete (forward delete)
-- We use <C-o> to momentarily drop into Normal mode, execute 'dw', then return
vim.keymap.set("i", "<C-Del>", "<C-o>dw", { noremap = true })

