local telescope = require("telescope")

telescope.setup {
  defaults = {
    file_ignore_patterns = { "node_modules", "vendor" },
  },
  pickers = {
    -- Include files normally ignored by .gitignore (like .env)
    find_files = {
      hidden = true,
      no_ignore = true,
      no_ignore_parent = true,
    },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--no-ignore", "--no-ignore-parent" }
      end,
    },
    grep_string = {
      additional_args = function()
        return { "--hidden", "--no-ignore", "--no-ignore-parent" }
      end,
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {},
    },
  },
}

pcall(telescope.load_extension, "ui-select")
