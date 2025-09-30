-- Persist per-project format-on-save settings and provide toggles.

local M = {}

local uv = vim.uv or vim.loop

-- Persist under stdpath('config') so it’s stow-managed by this repo
-- and portable across machines when you sync dotfiles.
local STATE_FILE = (vim.fn.stdpath("config") .. "/format-on-save.json")
local LOCAL_STATE_FILE = (vim.fn.stdpath("config") .. "/format-on-save.local.json")

local function ensure_parent(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
end

local function read_file(path)
  if vim.fn.filereadable(path) ~= 1 then return nil end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines then return nil end
  return table.concat(lines, "\n")
end

local function write_file(path, content)
  ensure_parent(path)
  return pcall(vim.fn.writefile, { content }, path)
end

local function json_decode(s)
  if not s or s == "" then return nil end
  local ok, decoded = pcall(vim.json.decode, s)
  if ok then return decoded end
  -- fallback for older versions
  local ok2, decoded2 = pcall(vim.fn.json_decode, s)
  if ok2 then return decoded2 end
  return nil
end

local function json_encode(tbl)
  local ok, enc = pcall(vim.json.encode, tbl)
  if ok then return enc end
  return vim.fn.json_encode(tbl)
end

-- in-memory caches
-- BASE: contents of STATE_FILE; LOCAL: contents of LOCAL_STATE_FILE
-- MERGED: effective view with LOCAL overriding BASE
local BASE, LOCAL, MERGED = nil, nil, nil

local function load_state()
  if MERGED ~= nil then return MERGED end
  local base_raw = read_file(STATE_FILE)
  local local_raw = read_file(LOCAL_STATE_FILE)
  BASE = json_decode(base_raw) or {}
  LOCAL = json_decode(local_raw) or {}
  if type(BASE) ~= "table" then BASE = {} end
  if type(LOCAL) ~= "table" then LOCAL = {} end
  MERGED = vim.tbl_extend("force", {}, BASE, LOCAL)
  return MERGED
end

local function save_state()
  if not BASE then return end
  write_file(STATE_FILE, json_encode(BASE))
end

-- Heuristic: prefer LSP root; otherwise search for common project markers; fallback to cwd
local function detect_root(bufnr)
  bufnr = bufnr or 0

  -- LSP clients root (most accurate)
  if vim.lsp then
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, c in ipairs(clients) do
      local root = c.config and c.config.root_dir or c.root_dir
      if root and root ~= "" then return vim.fs.normalize(root) end
    end
  end

  -- Search upward for markers
  local name = vim.api.nvim_buf_get_name(bufnr)
  local start = name ~= "" and vim.fs.dirname(name) or uv.cwd()
  local markers = {
    ".git",
    "package.json",
    "pnpm-workspace.yaml",
    "yarn.lock",
    "composer.json",
    "pyproject.toml",
    "poetry.lock",
    "go.mod",
    "Cargo.toml",
    "Gemfile",
    "Makefile",
  }
  local found = vim.fs.find(markers, { upward = true, path = start })
  if #found > 0 then
    return vim.fs.dirname(found[1])
  end

  return vim.fs.normalize(uv.cwd())
end

-- Try to derive a stable project id across machines.
-- Priority:
-- 1) git remote (origin url normalized)
-- 2) git toplevel path basename
-- 3) detected root path
local function git_info(start)
  local root = nil
  local gitdir = vim.fs.find(".git", { upward = true, path = start })[1]
  if gitdir then root = vim.fs.dirname(gitdir) end
  if not root then return nil end

  local function sys(cmd, cwd)
    local ok, res = pcall(function()
      if vim.system then
        local out = vim.system(cmd, { cwd = cwd }):wait()
        if out.code == 0 then return (out.stdout or "") end
        return nil
      else
        local joined = table.concat(cmd, " ")
        local out = vim.fn.systemlist("cd " .. vim.fn.shellescape(cwd) .. " && " .. joined)
        if vim.v.shell_error == 0 and type(out) == "table" then return table.concat(out, "\n") end
        return nil
      end
    end)
    if not ok then return nil end
    return res
  end

  local remote = sys({ "git", "config", "--get", "remote.origin.url" }, root)
  if remote then remote = vim.trim(remote) end

  local id = nil
  if remote and remote ~= "" then
    -- Normalize common forms
    -- git@host:owner/repo(.git)? -> host/owner/repo
    local host, path = remote:match("git@([^:]+):(.+)")
    if not host then
      -- https?://host/owner/repo(.git)?
      host, path = remote:match("https?://([^/]+)/(.+)")
    end
    if not host then
      -- ssh://git@host/owner/repo(.git)?
      host, path = remote:match("ssh://[^@]+@([^/]+)/(.+)")
    end
    if host and path then
      path = path:gsub("%.git$", "")
      id = string.format("git:%s/%s", host, path)
    else
      id = string.format("git:%s", remote)
    end
  end

  if not id then
    local top = sys({ "git", "rev-parse", "--show-toplevel" }, root)
    if top and top ~= "" then
      local base = vim.fn.fnamemodify(vim.trim(top), ":t")
      id = string.format("git:%s", base)
    end
  end

  return id or nil
end

local function project_key(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local start = name ~= "" and vim.fs.dirname(name) or uv.cwd()
  local git_id = git_info(start)
  if git_id then return git_id end
  return detect_root(bufnr)
end

function M.is_enabled(bufnr)
  local key = project_key(bufnr)
  local st = load_state()
  local v = st[key]
  return v == true -- default off when nil/false
end

local function set(bufnr, enabled)
  local key = project_key(bufnr)
  -- Determine write target: 'config' (default) or 'local'
  local target = vim.g.format_toggle_write_target or "config"
  load_state()
  if target == "local" then
    LOCAL = LOCAL or {}
    LOCAL[key] = enabled and true or false
    -- merge view
    MERGED[key] = LOCAL[key]
    -- persist only local file
    write_file(LOCAL_STATE_FILE, json_encode(LOCAL))
  else
    BASE = BASE or {}
    BASE[key] = enabled and true or false
    MERGED[key] = BASE[key]
    save_state()
  end
  return key, MERGED[key]
end

function M.enable(bufnr)
  local key = select(1, set(bufnr, true))
  vim.notify("Autoformat: enabled for " .. key)
end

function M.disable(bufnr)
  local key = select(1, set(bufnr, false))
  vim.notify("Autoformat: disabled for " .. key)
end

function M.toggle(bufnr)
  local enabled = M.is_enabled(bufnr)
  local key = select(1, set(bufnr, not enabled))
  vim.notify(((not enabled) and "Enabled" or "Disabled") .. " autoformat for " .. key)
end

function M.setup_user_commands()
  vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
    M.toggle(0)
  end, { desc = "Toggle autoformat-on-save for current project" })

  vim.api.nvim_create_user_command("FormatOnSaveEnable", function()
    M.enable(0)
  end, { desc = "Enable autoformat-on-save for current project" })

  vim.api.nvim_create_user_command("FormatOnSaveDisable", function()
    M.disable(0)
  end, { desc = "Disable autoformat-on-save for current project" })
end

return M
