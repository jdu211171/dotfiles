require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Terminal: Shift+Esc leaves Terminal-Job mode (to Terminal-Normal)
map("t", "<S-Esc>", [[<C-\><C-n>]], { desc = "Terminal: exit to Normal mode" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Copilot: toggle suggestions on/off
map("n", "<leader>tc", function()
  local function do_toggle()
    local suggestion = require("copilot.suggestion")
    suggestion.toggle_auto_trigger()
    local cfg = require("copilot.config")
    local on = cfg.get().suggestion and cfg.get().suggestion.auto_trigger
    vim.notify("Copilot suggestions: " .. ((on and "ON") or "OFF"))
  end

  if not pcall(do_toggle) then
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
      pcall(lazy.load, { plugins = { "copilot.lua" } })
      pcall(do_toggle)
    else
      vim.notify("Copilot not loaded and lazy not available", vim.log.levels.WARN)
    end
  end
end, { desc = "Copilot: toggle suggestions" })

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
