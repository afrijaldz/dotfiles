require "nvchad.options"

-- add yours here!

local o = vim.o


-- line numbers
o.relativenumber = true
o.number = true

-- tabs & indentation
-- o.tabstop = 2
-- o.shiftwidth = 2
-- o.expandtab = true
-- o.autoindent = true

-- line wrapping
o.wrap = false

-- search settings
o.smartcase = true

-- cursor line
o.cursorline = true

-- appearance
o.termguicolors = true
o.background = "dark"
o.signcolumn = "yes"

-- backspace
o.backspace = "indent,eol,start"
