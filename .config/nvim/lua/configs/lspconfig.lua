-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end


-- typescript
-- lspconfig.tsserver.setup {
--   on_attach = on_attach,
--   on_init = on_init,
--   capabilities = capabilities,
--
--   init_options = {
--     plugins = {
--       {
--         name = "@vue/typescript-plugin",
--         location = "/home/kang/.nvm/versions/node/v22.11.0/lib/node_modules/@vue/language-server",
--         languages = { "vue" },
--       }
--     }
--   },
--   filetypes = {
--     "javascript",
--     "typescript",
--     "typescriptreact",
--   }
-- }

lspconfig.ts_ls.setup {}


lspconfig.volar.setup {
  -- filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" }
}

lspconfig.astro.setup {
}


lspconfig.gopls.setup {
}

lspconfig.pylsp.setup {
}

lspconfig.ruby_lsp.setup {}
