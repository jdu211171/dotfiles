vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- Enable OSC 52 clipboard for SSH / headless environments (copies to host Mac clipboard)
if vim.fn.has "clipboard" == 0 or vim.env.SSH_TTY or vim.env.SSH_CLIENT or vim.env.SSH_CONNECTION then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    local function paste()
      return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" }
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy "+",
        ["*"] = osc52.copy "*",
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
    vim.g.loaded_clipboard_provider = nil
    vim.cmd "runtime autoload/provider/clipboard.vim"
  end
end

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
