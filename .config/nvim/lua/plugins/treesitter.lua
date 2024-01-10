return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "windwp/nvim-ts-autotag" },
    },
    opts = {
      highlight = { enable = true },
      autopairs = { enable = true },
      autotag = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "vue",
        "yaml",
      },
    },
  },
}
