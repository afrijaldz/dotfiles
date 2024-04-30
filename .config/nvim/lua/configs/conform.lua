local options = {
  ft_parsers = {
    --     javascript = "babel",
    --     javascriptreact = "babel",
    typescript = "typescript",
    --     typescriptreact = "typescript",
    vue = "vue",
    --     css = "css",
    --     scss = "scss",
    --     less = "less",
    html = "html",
    --     json = "json",
    --     jsonc = "json",
    --     yaml = "yaml",
    --     markdown = "markdown",
    --     ["markdown.mdx"] = "mdx",
    --     graphql = "graphql",
    --     handlebars = "glimmer",
  },
  formatters_by_ft = {
    javascript = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    vue = { 'prettier', 'prettierd' }
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
