return {
  -- GitHub Copilot core (completion backend required by CopilotChat)
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      filetypes = {
        ["*"] = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          -- Friendlier inline suggestion workflow
          accept = "<Tab>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      local suggestion = require("copilot.suggestion")

      local function fallback(key)
        return vim.api.nvim_replace_termcodes(key, true, false, true)
      end

      local function accept_word_or_fallback(key)
        if suggestion.is_visible() then
          suggestion.accept_word()
          return "<Ignore>"
        end
        return fallback(key)
      end

      local function accept_line_or_fallback(key)
        if suggestion.is_visible() then
          suggestion.accept_line()
          return "<Ignore>"
        end
        return fallback(key)
      end

      vim.keymap.set("i", "<M-Right>", function()
        return accept_word_or_fallback("<M-Right>")
      end, { expr = true, silent = true, desc = "Copilot accept word (Alt+Right)" })

      vim.keymap.set("i", "<End>", function()
        return accept_line_or_fallback("<End>")
      end, { expr = true, silent = true, desc = "Copilot accept line (End)" })

      vim.keymap.set("i", "<S-Tab>", function()
        suggestion.next()
        return "<Ignore>"
      end, { expr = true, silent = true, desc = "Copilot trigger suggestion (Shift+Tab)" })
    end,
  },

  -- Copilot Chat UI and features
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>",   desc = "Copilot Chat - Toggle" },
      { "<leader>co", "<cmd>CopilotChatOpen<cr>",     desc = "Copilot Chat - Open" },
      { "<leader>cq", "<cmd>CopilotChatClose<cr>",    desc = "Copilot Chat - Close" },
      { "<leader>cs", "<cmd>CopilotChatStop<cr>",     desc = "Copilot Chat - Stop output" },
      { "<leader>cr", "<cmd>CopilotChatReset<cr>",    desc = "Copilot Chat - Reset" },
      { "<leader>cP", "<cmd>CopilotChatPrompts<cr>",  desc = "Copilot Chat - Prompts" },
      { "<leader>cM", "<cmd>CopilotChatModels<cr>",   desc = "Copilot Chat - Models" },
      -- Common built-in prompt commands
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>",  desc = "Copilot Chat - Explain" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>",      desc = "Copilot Chat - Fix" },
      { "<leader>cR", "<cmd>CopilotChatReview<cr>",   desc = "Copilot Chat - Review" },
      { "<leader>cO", "<cmd>CopilotChatOptimize<cr>", desc = "Copilot Chat - Optimize" },
      { "<leader>cD", "<cmd>CopilotChatDocs<cr>",     desc = "Copilot Chat - Docs" },
      { "<leader>cT", "<cmd>CopilotChatTests<cr>",    desc = "Copilot Chat - Tests" },
      { "<leader>cC", "<cmd>CopilotChatCommit<cr>",   desc = "Copilot Chat - Commit msg" },
    },
    opts = {
      model = 'gpt-5',
      temperature = 0.1,
      auto_insert_mode = true,
      window = {
        layout = "vertical",
        width = 0.4,
        border = "rounded",
        title = "🤖 Copilot Chat",
        zindex = 100,
      },
      -- Prefer visual selection, fallback to current line
      selection = function(source)
        return require("CopilotChat.select").visual(source)
          or require("CopilotChat.select").line(source)
      end,
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      -- Friendlier behavior in chat buffers
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })

      -- For Neovim < 0.11, ensure good completion behavior in the chat
      local ver = vim.version()
      if ver and (ver.major == 0 and ver.minor < 11) then
        vim.opt.completeopt:append({ "noinsert", "popup" })
      end
    end,
  },
}
