local options = {
  ft_parsers = {
    -- css = { "prettier" },
    typescript = "typescript",
    vue = "vue",
    html = "html"
  },
  formatters_by_ft = {
    javascript = { { "prettier", "prettierd" } },
    typescript = { { "prettier", "prettierd" } },
    vue = { { "prettier", "prettierd" } },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
