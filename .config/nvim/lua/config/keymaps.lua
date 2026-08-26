-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit Insert mode" })
vim.keymap.set("t", "jj", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Seamless nvim-split / tmux-pane navigation — overrides LazyVim's <C-w>hjkl
-- versions, which stop at the edge of nvim instead of crossing into tmux.
-- See lua/plugins/tmux-navigator.lua.
vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { desc = "Go to left split/pane" })
vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { desc = "Go to lower split/pane" })
vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { desc = "Go to upper split/pane" })
vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { desc = "Go to right split/pane" })
vim.keymap.set("n", "<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", { desc = "Go to previous split/pane" })
