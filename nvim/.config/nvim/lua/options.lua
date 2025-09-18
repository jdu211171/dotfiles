require "nvchad.options"

-- add yours here!
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.blade.php",
  command = "set filetype=blade",
})

-- Treat .env files as shell-like for Treesitter highlighting
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { ".env", ".env.*", "*.env" },
  callback = function()
    vim.bo.filetype = "sh"
  end,
})

local o = vim.o
o.relativenumber = true
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Navigate VIM panes with Ctrl + hjkl
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")

-- Ensure terminal buffers show relative numbers consistently
-- Use several events to override plugins that may toggle numbers.
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter", "WinEnter" }, {
  pattern = "term://*",
  desc = "Enable number & relativenumber in terminals",
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
  end,
})
