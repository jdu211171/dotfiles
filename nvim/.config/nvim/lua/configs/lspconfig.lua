-- load NVChad defaults (capabilities/on_init/on_attach)
require("nvchad.configs.lspconfig").defaults()

-- Merge capabilities so LSP servers receive file-operations support
-- (needed for updating imports on file renames/moves)
local ok_lfo, lfo = pcall(require, "lsp-file-operations")
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_lfo then
  local base = vim.lsp.protocol.make_client_capabilities()
  if ok_cmp then base = cmp.default_capabilities(base) end
  local caps = vim.tbl_deep_extend("force", base, lfo.default_capabilities())
  vim.lsp.config("*", { capabilities = caps })
end

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
