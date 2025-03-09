-- lua/utils.lua

local M = {}

function M.has_local_config(location, config_names)
  -- We'll iterate over each possible config name, looking upward.
  for _, config_name in ipairs(config_names) do
    -- Use the "path" key so Neovim can search upward from 'location'
    local found = vim.fs.find(config_name, { upward = true, path = location })
    if not vim.tbl_isempty(found) then
      return true
    end
  end
  return false
end

return M
