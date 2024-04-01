vim.cmd('colorscheme monokai')

local status, _ = pcall(vim.cmd, 'colorscheme monokai')
if not status then
	print("Colorscheme not found")
	return
end
