-- Ctrl+h/j/k/l moves across nvim splits AND tmux panes as one flat grid.
--
-- The tmux half already exists (the `is_vim` block in .config/tmux/tmux.conf):
-- when the focused pane runs nvim, tmux forwards the key instead of moving the
-- pane itself. This plugin is the other half — it moves an nvim split when
-- there is one in that direction, and hands the key back to tmux when the
-- cursor is already at the edge. Without it the key dead-ends inside nvim.
--
-- Mappings live in lua/config/keymaps.lua, not here: LazyVim binds these same
-- four keys to <C-w>hjkl on VeryLazy, which would overwrite anything this spec
-- sets. config/keymaps.lua is loaded after that, so it wins.
return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
