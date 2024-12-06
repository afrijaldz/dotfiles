require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>nh", ":nohl<CR>")
map("n", "x", '"_x')
map("n", "<leader>+", "<C-a>")
map("n", "<leader>-", "<C-x>")
map("n", "<leader>sv", "<C-w>v")        -- split window vertically
map("n", "<leader>sh", "<C-w>s")        -- split window horizontally
map("n", "<leader>se", "<C-w>=")        -- make split windows equal width
map("n", "<leader>sx", ":close<CR>")    -- close current split window

map("n", "<leader>to", ":tabnew<CR>")   -- open new tab
map("n", "<leader>tx", ":tabclose<CR>") -- close current tab
map("n", "<leader>tn", ":tabn<CR>")     --  go to next tab
map("n", "<leader>tp", ":tabp<CR>")     --  go to previous tab
