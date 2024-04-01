vim.g.mapleader = " "
vim.g.blamer_enabled = 1
vim.g.blamer_show_in_insert_modes = 1


local keymap = vim.keymap

keymap.set("i", "jj", "<ESC>")

-- nvim-tree
keymap.set("n", "<C-B>", ":NvimTreeToggle<CR>")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
--[[ vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
map("n", "<C-P>", ":Telescope find_files<CR>")
map("n", "<C-O>", ":Telescope live_grep<CR>") ]]
