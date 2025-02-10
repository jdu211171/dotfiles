local M = {}

M["php-cs-fixer"] = {
  command = "php-cs-fixer",
  args = { "fix", "--config=default", "$FILENAME" },
  stdin = false,
  cwd = require("conform.util").root_file {
    ".php-cs-fixer.dist.php",
    ".php-cs-fixer.php",
    ".php-cs-fixer",
  },
  condition = function(ctx)
    return ctx.filename:match "%.php$" ~= nil
  end,
  config_names = {
    ".php-cs-fixer.dist.php",
    ".php-cs-fixer.php",
    ".php-cs-fixer",
  },
  config_command = "--config",
  config_path = "~/configs/php/.php-cs-fixer.dist.php", -- Path to your default config
  continuous_string = true,
}

return M
