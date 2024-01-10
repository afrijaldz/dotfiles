local setup, blamer = pcall(require, "blamer")
if not setup then
  return
end

vim.g.blamer_enabled = 1

blamer.setup()
