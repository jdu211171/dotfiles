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
