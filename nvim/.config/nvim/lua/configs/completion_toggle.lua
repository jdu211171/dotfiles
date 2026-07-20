local M = {}

local state = {
  auto_popup = vim.g.cmp_auto_popup_enabled,
  snippets = vim.g.cmp_snippets_enabled,
}

if state.auto_popup == nil then
  state.auto_popup = true
end

if state.snippets == nil then
  state.snippets = true
end

local base_sources

local function autocomplete_events()
  local ok, types = pcall(require, "cmp.types")
  if not ok then
    return { "TextChanged" }
  end

  return { types.cmp.TriggerEvent.TextChanged }
end

local function sync_globals()
  vim.g.cmp_auto_popup_enabled = state.auto_popup
  vim.g.cmp_snippets_enabled = state.snippets
end

local function notify(message)
  vim.notify(message, vim.log.levels.INFO)
end

function M.auto_popup_enabled()
  return state.auto_popup ~= false
end

function M.snippets_enabled()
  return state.snippets ~= false
end

function M.filtered_sources(sources)
  if M.snippets_enabled() then
    return vim.deepcopy(sources or {})
  end

  local filtered = {}
  for _, source in ipairs(sources or {}) do
    if source.name ~= "luasnip" then
      table.insert(filtered, vim.deepcopy(source))
    end
  end

  return filtered
end

function M.apply_to_opts(opts)
  opts = opts or {}

  if not base_sources and opts.sources then
    base_sources = vim.deepcopy(opts.sources)
  end

  opts.completion = opts.completion or {}
  opts.completion.autocomplete = M.auto_popup_enabled() and autocomplete_events() or false

  if base_sources then
    opts.sources = M.filtered_sources(base_sources)
  end

  sync_globals()

  return opts
end

function M.apply()
  local ok_cmp, cmp = pcall(require, "cmp")
  if not ok_cmp then
    sync_globals()
    return
  end

  if not base_sources then
    local ok_config, config = pcall(require, "cmp.config")
    if ok_config then
      base_sources = vim.deepcopy(config.get().sources or {})
    end
  end

  cmp.setup {
    completion = {
      autocomplete = M.auto_popup_enabled() and autocomplete_events() or false,
    },
    sources = M.filtered_sources(base_sources or {}),
  }

  if cmp.visible() then
    cmp.close()
  end

  sync_globals()
end

function M.toggle_auto_popup()
  state.auto_popup = not M.auto_popup_enabled()
  M.apply()
  notify("Completion auto popup: " .. (M.auto_popup_enabled() and "enabled" or "disabled"))
end

function M.toggle_snippets()
  state.snippets = not M.snippets_enabled()
  M.apply()
  notify("Completion snippets: " .. (M.snippets_enabled() and "enabled" or "disabled"))
end

function M.quiet_enabled()
  return not M.auto_popup_enabled() and not M.snippets_enabled()
end

function M.toggle_quiet()
  local enable_quiet = not M.quiet_enabled()

  state.auto_popup = not enable_quiet
  state.snippets = not enable_quiet

  M.apply()
  notify("Completion quiet mode: " .. (enable_quiet and "enabled" or "disabled"))
end

function M.setup_user_commands()
  local function create_command(name, callback, desc)
    pcall(vim.api.nvim_del_user_command, name)
    vim.api.nvim_create_user_command(name, callback, { desc = desc })
  end

  create_command("CompletionAutoToggle", function()
    M.toggle_auto_popup()
  end, "Toggle automatic completion popup")

  create_command("CompletionSnippetsToggle", function()
    M.toggle_snippets()
  end, "Toggle snippet completions")

  create_command("CompletionQuietToggle", function()
    M.toggle_quiet()
  end, "Toggle quiet completion mode")
end

return M
