local configs_location = vim.fn.stdpath "config" .. "/configs/"
local utils = require "utils"

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
    format_on_save = {
      lsp_fallback = true,
      async = true,
      timeout_ms = 500,
    },
  }
  for formatter, formatter_settings in pairs(formatters_opts) do
    formatter = formatter:gsub("_", "-")
    formatters[formatter] = {
      prepend_args = function(_, ctx)
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
      end,
    }
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
      json = { "prettier" },
      jsonc = { "prettier" },
      markdown = { "prettier" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      yaml = { "prettier" },
      php = { "pint" },
      blade = { "blade-formatter" },
    },
    formatters = formatters,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  }
end

return M
