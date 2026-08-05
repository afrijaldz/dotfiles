-- Monokai, light style.
--
-- Monokai has no official light variant; monokai-nightasty ships one and picks
-- the style from `vim.o.background`, so the background has to be set before the
-- theme loads. That is why the colorscheme is a function instead of a name.
return {
  {
    "polirritmico/monokai-nightasty.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      light_style_background = "default", -- default | dark | transparent | #RRGGBB
      markdown_header_marks = true,
    },
    keys = {
      { "<leader>ut", "<Cmd>MonokaiToggleLight<CR>", desc = "Toggle dark/light theme" },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.o.background = "light"
        require("monokai-nightasty").load()
      end,
    },
  },
}
