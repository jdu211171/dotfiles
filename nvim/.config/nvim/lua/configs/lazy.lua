-- Ensure lazy.nvim's lockfile is saved inside the dotfiles repo even when
-- ~/.config/nvim is a real directory (stow-managed per file). We compute the
-- repo path by resolving this file's real path and walking up to .config/nvim.
local function dotfiles_config_dir()
  local src = debug.getinfo(1, 'S').source
  if src:sub(1, 1) == '@' then src = src:sub(2) end
  local real = vim.fn.resolve(src)
  -- real is .../dotfiles/nvim/.config/nvim/lua/configs/lazy.lua
  return vim.fn.fnamemodify(real, ':h:h:h') -- -> .../dotfiles/nvim/.config/nvim
end

return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },
  -- Disable LuaRocks/Hererocks integration to silence health warnings
  -- (no plugins in this config require it)
  rocks = { enabled = false },
  -- Make lockfile live in the repo so updates are tracked reliably
  lockfile = (dotfiles_config_dir() .. "/lazy-lock.json"),

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
