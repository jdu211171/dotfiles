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

-- Ensure sessions restore local window/buffer options & filetypes correctly
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

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

-- Optionally open NvDash on startup when no file/dir is provided
-- (We keep NvChad's built-in `nvdash.load_on_startup` disabled to avoid a
-- rare race that throws "Invalid window id: -1" in some environments.)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only when launched with no args and current buffer isn't modified
    if vim.fn.argc() ~= 0 then return end
    local opening = vim.api.nvim_buf_get_name(0)
    local is_dir = vim.fn.isdirectory(opening) == 1
    local modified = vim.api.nvim_get_option_value("modified", { buf = 0 })
    if modified or not (is_dir or opening == "") then return end

    vim.schedule(function()
      if not vim.bo.buflisted then vim.cmd.enew() end
      pcall(function()
        require("nvchad.nvdash").open()
      end)
    end)
  end,
})
