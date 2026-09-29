-- load NVChad defaults (capabilities/on_init/on_attach)
require("nvchad.configs.lspconfig").defaults()

-- Merge capabilities so LSP servers receive file-operations support
-- (needed for updating imports on file renames/moves)
local ok_lfo, lfo = pcall(require, "lsp-file-operations")
local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if ok_lfo then
  local base = vim.lsp.protocol.make_client_capabilities()
  if ok_cmp then
    base = cmp.default_capabilities(base)
  end
  local caps = vim.tbl_deep_extend("force", base, lfo.default_capabilities())
  vim.lsp.config("*", { capabilities = caps })
end

-- servers to enable (Neovim 0.11+ new API only)
local typescript_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

local typescript_root_markers = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
  "tsconfig.json",
  "jsconfig.json",
  "package.json",
  ".git",
}

local function project_uses_typescript_7(root)
  local package_json = vim.fs.joinpath(root, "node_modules", "typescript", "package.json")
  local ok, contents = pcall(vim.fn.readfile, package_json)
  if not ok or not contents or #contents == 0 then
    return false
  end

  local decoded, package = pcall(vim.json.decode, table.concat(contents, "\n"))
  local major = decoded and package.version and tonumber(package.version:match("^(%d+)"))
  return major ~= nil and major >= 7
end

-- TypeScript 7 ships its own native LSP; ts_ls wraps tsserver and requires TS < 7.
vim.lsp.config("ts_ls", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, typescript_root_markers) or vim.fn.getcwd()
    if not project_uses_typescript_7(root) then
      on_dir(root)
    end
  end,
})

-- Use the project's TypeScript 7 executable only for TS 7 workspaces.
vim.lsp.config("ts7", {
  cmd = function(dispatchers, config)
    local tsc = vim.fs.joinpath(config.root_dir, "node_modules", ".bin", "tsc")
    if vim.fn.executable(tsc) ~= 1 then
      tsc = "tsc"
    end
    return vim.lsp.rpc.start({ tsc, "--lsp", "--stdio" }, dispatchers)
  end,
  filetypes = typescript_filetypes,
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, typescript_root_markers) or vim.fn.getcwd()
    if project_uses_typescript_7(root) then
      on_dir(root)
    end
  end,
})

local servers = { "html", "cssls", "ts_ls", "ts7" }

for _, name in ipairs(servers) do
  -- NVChad defaults() already set global opts via vim.lsp.config("*", ...)
  vim.lsp.enable(name)
end

-- Example: per‑server customization
-- vim.lsp.config("ts_ls", {
--   -- settings = { ... },
-- })
-- vim.lsp.enable("ts_ls")
