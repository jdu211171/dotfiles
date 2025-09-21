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

  -- Disable auto popup completion from nvim-cmp; manual trigger only
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.autocomplete = false
      return opts
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
    -- Disable features that require missing parsers/tools to clear health warnings
    opts = {
      html = { enabled = false },
      latex = { enabled = false },
      yaml = { enabled = false },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
    event = { "BufReadPost", "BufNewFile" },
  },

  -- TMUX + Neovim navigation
  -- Use alexghergh/nvim-tmux-navigation to support a "Next" action.
  -- Maps: <C-h/j/k> are directional; <C-l> cycles: Nvim → Nvim-term → next tmux pane.
  {
    "alexghergh/nvim-tmux-navigation",
    lazy = false,
    config = function()
      local nav = require "nvim-tmux-navigation"
      nav.setup { disable_when_zoomed = true }

      local map = function(lhs, fn)
        vim.keymap.set({ "n", "t" }, lhs, fn, { silent = true })
      end

      map("<C-h>", nav.NvimTmuxNavigateLeft)
      map("<C-j>", nav.NvimTmuxNavigateDown)
      map("<C-k>", nav.NvimTmuxNavigateUp)
      -- Use <C-l> as "Next" to match desired repeated-press behavior
      map("<C-l>", nav.NvimTmuxNavigateNext)
      -- Optional: jump to last active split/pane
      -- map("<C-\\>", nav.NvimTmuxNavigateLastActive)
    end,
  },

  -- VIM Fugitive
  {
    "tpope/vim-fugitive",
  },

  -- nvim-tree: show .env and other dotfiles
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
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
