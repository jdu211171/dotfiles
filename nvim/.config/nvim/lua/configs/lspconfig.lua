-- load NVChad defaults (capabilities/on_init/on_attach)
require("nvchad.configs.lspconfig").defaults()

-- servers to enable (Neovim 0.11+ new API only)
local servers = { "html", "cssls", "ts_ls" }

for _, name in ipairs(servers) do
  -- NVChad defaults() already set global opts via vim.lsp.config("*", ...)
  vim.lsp.enable(name)
end

-- Example: per‑server customization
-- vim.lsp.config("ts_ls", {
--   -- settings = { ... },
-- })
-- vim.lsp.enable("ts_ls")
