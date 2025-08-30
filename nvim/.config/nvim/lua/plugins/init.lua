return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    lazy = false,
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
  -- {
  --   "github/copilot.vim",
  --   lazy = false,
  -- },
  -- Use these two plugins instead for GitHub Copilot Chat

  -- CopilotChat moved to its own spec in lua/plugins/copilotchat.lua

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
    keys = {
      { "<leader>ls", "<cmd>Telescope session-lens<cr>", desc = "Search session" },
    },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require "configs.telescope"
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
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

  -- nvim-tree: show .env and other dotfiles
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        -- do not hide dotfiles; ensures .env is visible
        dotfiles = false,
        -- keep any custom filters empty unless you want to hide patterns
        custom = {},
        -- explicitly ensure these are never filtered
        exclude = { ".env", ".env.*" },
      },
      git = {
        -- show files even if they are in .gitignore (common for .env)
        ignore = false,
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
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
