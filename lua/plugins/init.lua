return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    lazy = false,
    config = function()
      require("configs.conform").setup()
    end,
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format { async = true, lsp_fallback = true }
        end,
        mode = "n",
        desc = "Format buffer",
      },
    },
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
      require "configs.auto-session"
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require "configs.telescope"
    end,
  },

  -- Markdown Support
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    opts = {}, -- additional options can be specified here
    config = function()
      require("render-markdown").setup {}
    end,
    event = { "BufReadPost", "BufNewFile" },
  },

  -- TMUX Navigator
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    vim.keymap.set("n", "C-h", ":TmuxNavigateLeft<CR>"),
    vim.keymap.set("n", "C-j", ":TmuxNavigateDown<CR>"),
    vim.keymap.set("n", "C-k", ":TmuxNavigateUp<CR>"),
    vim.keymap.set("n", "C-l", ":TmuxNavigateRight<CR>"),
  },

  -- VIM Fugitive
  {
    "tpope/vim-fugitive",
  },

  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    keys = {
      {
        "<leader>zz",
        function()
          require("zen-mode").toggle()
        end,
        mode = "n",
        desc = "Toggle Zen Mode",
      },
    },
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
