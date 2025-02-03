return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    lazy = false,
  },

  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "configs.gitsigns"
    end,
  },

  -- Sessions
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require "auto-session".setup({
        auto_session_suppress_dirs = { "~/", "~/Development", "~/Downloads", "/" },
        session_lens = {
          buftypes_to_ignore = {},
          load_on_setup = true,
          theme_conf = { border = true },
          preveiwer = false,
        },
        vim.keymap.set("n", "<leader>ls", require("auto-session.session-lens").search_session, {
        noremap = true
      }),
    })
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
