require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Do NOT hijack plain <Esc> so zsh vi-mode keeps working
-- Provide reliable alternatives that do not need extended-keys
map("t", "<C-\\>", [[<C-\><C-n>]], { desc = "Terminal: exit to Normal (Ctrl-\\)" })
map("t", "<C-g>", [[<C-\><C-n>]], { desc = "Terminal: exit to Normal (Ctrl-g)" })
map("t", "<M-q>", [[<C-\><C-n>]], { desc = "Terminal: exit to Normal (Alt-q)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Utility: copy current file's relative path
map("n", "<leader>yp", function()
  local rel = vim.fn.expand("%:.")
  if rel == nil or rel == "" then
    vim.notify("No file path for this buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", rel)
  vim.notify("Copied relative path: " .. rel)
end, { desc = "Yank relative path to clipboard" })

-- Utility: copy @file:<relative> for Copilot Chat mentions
map("n", "<leader>yf", function()
  local rel = vim.fn.expand("%:.")
  if rel == nil or rel == "" then
    vim.notify("No file path for this buffer", vim.log.levels.WARN)
    return
  end
  local mention = "@file:" .. rel
  vim.fn.setreg("+", mention)
  vim.notify("Copied: " .. mention)
end, { desc = "Yank @file:<relative> to clipboard" })

-- NvDash: open dashboard safely on demand
map("n", "<leader>nd", function()
  if not vim.bo.buflisted then
    vim.cmd.enew()
  end
  require("nvchad.nvdash").open()
end, { desc = "NvDash: Open dashboard" })

-- Final override: ensure Ctrl-h/j/k/l are mapped after all other mappings load.
-- Uses nvim-tmux-navigation when available; otherwise falls back to :wincmd.
do
  local ok, nav = pcall(require, "nvim-tmux-navigation")
  local function fallback(cmd)
    return function()
      -- Leave terminal mode if needed
      if vim.bo.buftype == "terminal" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      end
      vim.cmd(cmd)
    end
  end
  local mapdir = function(lhs, navfn, wincmd)
    vim.keymap.set({ "n", "t" }, lhs, (ok and navfn) or fallback(wincmd), { silent = true, noremap = true })
  end
  mapdir("<C-h>", ok and nav.NvimTmuxNavigateLeft,  "wincmd h")
  mapdir("<C-j>", ok and nav.NvimTmuxNavigateDown,  "wincmd j")
  mapdir("<C-k>", ok and nav.NvimTmuxNavigateUp,    "wincmd k")
  mapdir("<C-l>", ok and nav.NvimTmuxNavigateRight, "wincmd l")
end

-- Normal mode: Alt+Right/Left act like Tab/Shift-Tab
-- Use remap=true so buffer-local <Tab>/<S-Tab> mappings (e.g., Telescope) still trigger
map("n", "<M-Right>", "<Tab>",   { remap = true, silent = true, desc = "Normal: behave as <Tab> (Alt+Right)" })
map("n", "<M-Left>",  "<S-Tab>", { remap = true, silent = true, desc = "Normal: behave as <S-Tab> (Alt+Left)" })
