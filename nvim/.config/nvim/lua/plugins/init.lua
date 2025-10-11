return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    lazy = false,
    config = function()
      -- Configure formatters and enable format-on-save
      pcall(function()
        require("configs.conform").setup()
        -- Expose project-scoped toggle commands
        require("configs.format_toggle").setup_user_commands()
      end)
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
      {
        "<leader>la",
        function()
          require("configs.format_toggle").toggle(0)
        end,
        mode = "n",
        desc = "Toggle autoformat (project)",
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

  -- Project-wide search & replace UI (grug-far)
  {
    "MagicDuck/grug-far.nvim",
    version = "1.6.3", -- compatible with Neovim 0.10+; remove to track latest
    -- Register keymaps with lazy so mappings work before plugin loads
    keys = {
      {
        "<leader>sr",
        function()
          local cwd = vim.loop.cwd()
          local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")
          if type(out) == "table" and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
            cwd = out[1]
          end
          require("grug-far").open({ cwd = cwd, prefills = { search = vim.fn.expand("<cword>") } })
        end,
        mode = "n",
        desc = "Grug: search & replace (project)",
      },
      {
        "<leader>sr",
        function()
          local cwd = vim.loop.cwd()
          local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")
          if type(out) == "table" and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
            cwd = out[1]
          end
          require("grug-far").with_visual_selection({ cwd = cwd })
        end,
        mode = "x",
        desc = "Grug: search selection (project)",
      },
      {
        "<leader>sf",
        function()
          local cwd = vim.loop.cwd()
          local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")
          if type(out) == "table" and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
            cwd = out[1]
          end
          require("grug-far").open({ cwd = cwd, prefills = { paths = vim.fn.expand("%"), search = vim.fn.expand("<cword>") } })
        end,
        mode = "n",
        desc = "Grug: search in current file",
      },
      {
        "<leader>si",
        function()
          local cwd = vim.loop.cwd()
          local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")
          if type(out) == "table" and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
            cwd = out[1]
          end
          require("grug-far").open({ cwd = cwd, visualSelectionUsage = "operate-within-range" })
        end,
        mode = { "n", "x" },
        desc = "Grug: search within selection range",
      },
    },
    config = function()
      local ok, grug = pcall(require, "grug-far")
      if not ok then return end

      local function get_root()
        local cwd = vim.loop.cwd()
        local out = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")
        if type(out) == "table" and out[1] and out[1] ~= "" and vim.v.shell_error == 0 then
          return out[1]
        end
        return cwd
      end

      grug.setup {}

      -- We keep setup minimal; keys above trigger lazy-load and call APIs
      -- Users can run :GrugFar or use the keys to launch the panel
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
  -- Directional Ctrl-h/j/k/l across Neovim splits and tmux panes.
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
      map("<C-l>", nav.NvimTmuxNavigateRight)
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
