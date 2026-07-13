-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit Insert mode" })
vim.keymap.set("t", "jj", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
