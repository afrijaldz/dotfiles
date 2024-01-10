-- vim.cmd("colorscheme nightfly")
--
-- local status, _ = pcall(vim.cmd, "colorscheme nightfly")
-- if not status then
--   print("Colorscheme not found!")
--   return
-- end


vim.cmd("colorscheme monokai")

local status, _ = pcall(vim.cmd, "colorscheme monokai")
if not status then
  print("Colorscheme not found!")
  return
end
