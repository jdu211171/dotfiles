local configs_location = vim.fn.stdpath "config" .. "/configs/"
local utils = require "utils"
local util = require "conform.util"

local M = {}

function M.setup()
  -- Import formatters
  local formatters_opts = {}
  local formatter_files = { "prettier" }

  for _, name in ipairs(formatter_files) do
    local ok, fmt = pcall(require, "configs.conform.formatters." .. name)
    if ok then
      formatters_opts[name] = fmt[name]
    end
  end

  -- Build formatters configuration
  local formatters = {
    -- Prefer project-local Prettier and run from closest config root.
    -- If not installed locally, fall back to global `prettier` (parity with VS Code extension).
    prettier = {
      prefer_local = "node_modules/.bin",
      cwd = util.root_file {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.js",
        "prettier.config.js",
        "prettier.config.cjs",
        ".git",
      },
    },
    pint = {
      command = "php",
      args = { "vendon/bin/pint", "$FILENAME" },
      stdin = false,
    },
    blade_formatter = {
      command = "blade-formatter",
      args = { "--write", "$FILENAME" },
      stdin = false,
    },
  }
  for formatter, formatter_settings in pairs(formatters_opts) do
    formatter = formatter:gsub("_", "-")
    local existing = formatters[formatter] or {}
    existing.prepend_args = function(_, ctx)
      if utils.has_local_config(ctx.filename, formatter_settings.config_names) then
        return {}
      else
        if formatter_settings.continuous_string then
          return {
            formatter_settings.config_command .. configs_location .. formatter_settings.config_path,
          }
        else
          return {
            formatter_settings.config_command,
            configs_location .. formatter_settings.config_path,
          }
        end
      end
    end
    formatters[formatter] = existing
  end

  -- Conform setup
  require("conform").setup {
    log_level = vim.log.levels.WARN,
    formatters_by_ft = {
      lua = { "stylua" },
      css = { "prettier" },
      html = { "prettier" },
      c = { "clang-format" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      markdown = { "prettier" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      svelte = { "prettier" },
      astro = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      graphql = { "prettier" },
      yaml = { "prettier" },
      php = { "pint" },
      blade = { "blade-formatter" },
    },
    formatters = formatters,
    format_on_save = {
      -- Large monorepos sometimes need more than 500ms
      timeout_ms = 3000,
      lsp_fallback = false,
    },
  }
end

return M
