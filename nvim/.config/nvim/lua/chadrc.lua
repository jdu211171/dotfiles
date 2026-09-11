-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- Per-machine theme override: create ~/.config/nvim/lua/chadrc_local.lua
-- returning { theme = "your-theme" }. That file is gitignored.
local ok, local_cfg = pcall(require, "chadrc_local")
local theme = (ok and type(local_cfg) == "table" and local_cfg.theme) or "one_light"

M.base46 = {
  theme = theme,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

-- Avoid startup error from NvDash in some setups where the first
-- buffer/window isn't listed yet. Open it manually instead.
M.nvdash = { load_on_startup = false }
M.ui = {
  tabufline = {
    lazyload = false,
  },
}

M.term = {
  -- Show line numbers in NvChad's terminal windows
  winopts = { number = true, relativenumber = true },
  sizes = { sp = 0.5, vsp = 0.5, ["bo sp"] = 0.5, ["bo vsp"] = 0.5 },
  float = {
    relative = "editor",
    row = 0.3,
    col = 0.25,
    width = 0.5,
    height = 0.4,
    border = "single",
  },
}

return M
