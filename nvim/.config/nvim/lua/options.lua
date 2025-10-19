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
-- Live preview for :substitute — shows changes as you type the command
o.inccommand = "split"
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Ensure sessions restore local window/buffer options & filetypes correctly
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- NOTE: Leave <C-h/j/k/l> unmapped here.
-- nvim-tmux-navigation sets these in lua/plugins/init.lua to integrate
-- Neovim window movement with tmux panes. Local mappings here would
-- override the plugin and break cross-pane navigation inside tmux.

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

    -- Defer slightly to let lazy-loaded UI pieces settle, then open NvDash
    -- and clean up any stray, empty preview/placeholder windows some plugins
    -- may create during startup.
    vim.defer_fn(function()
      if not vim.bo.buflisted then vim.cmd.enew() end
      pcall(function()
        require("nvchad.nvdash").open()
      end)

      -- Close any extra windows that are just empty scratch buffers. This
      -- fixes an issue where a tiny "[No Name]" window appears above the
      -- dashboard on first launch and requires :q to dismiss.
      local current_tab = vim.api.nvim_get_current_tabpage()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
        if win ~= vim.api.nvim_get_current_win() then
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          local modified_buf = vim.api.nvim_get_option_value("modified", { buf = buf })
          if (name == nil or name == "") and bt == "" and not modified_buf then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
    end, 20)
  end,
})

-- Silently save files that are changed by LSP workspace edits (e.g.,
-- imports updated after file renames), and avoid cluttering the bufferline
-- with transient buffers created by those edits.
-- You can disable this behavior by setting:
--   vim.g.lsp_fileops_autowrite = false
vim.g.lsp_fileops_autowrite = vim.g.lsp_fileops_autowrite ~= false

do
  local util = vim.lsp.util
  if type(util.apply_workspace_edit) == "function" then
    local orig_apply = util.apply_workspace_edit

    util.apply_workspace_edit = function(workspace_edit, position_encoding)
      -- Collect potentially impacted buffers before applying edits
      local impacted = {}
      local function add_uri(uri)
        if not uri then return end
        local bufnr = vim.uri_to_bufnr(uri)
        if bufnr and bufnr > 0 then impacted[bufnr] = true end
      end
      if workspace_edit then
        if workspace_edit.documentChanges then
          for _, change in ipairs(workspace_edit.documentChanges) do
            -- text document edits carry a textDocument.uri
            if not change.kind and change.textDocument and change.textDocument.uri then
              add_uri(change.textDocument.uri)
            end
            -- rename/create/delete kinds don't carry edits themselves
          end
        elseif workspace_edit.changes then
          for uri, _ in pairs(workspace_edit.changes) do add_uri(uri) end
        end
      end

      -- Snapshot listed/visibility state
      local before = {}
      for bufnr in pairs(impacted) do
        before[bufnr] = {
          exists = (vim.fn.bufexists(bufnr) == 1),
          listed = pcall(function() return vim.bo[bufnr].buflisted end) and vim.bo[bufnr].buflisted or false,
          visible = (vim.fn.bufwinid(bufnr) ~= -1),
        }
      end

      local ret = orig_apply(workspace_edit, position_encoding)

      if vim.g.lsp_fileops_autowrite then
        -- Save any modified normal file buffers, then unlist those that
        -- weren’t visible before the edit (to avoid bufferline noise).
        for bufnr in pairs(impacted) do
          if vim.api.nvim_buf_is_loaded(bufnr)
            and vim.api.nvim_get_option_value("modified", { buf = bufnr })
            and vim.bo[bufnr].buftype == ""
            and vim.bo[bufnr].modifiable
            and not vim.bo[bufnr].readonly
          then
            pcall(vim.api.nvim_buf_call, bufnr, function()
              vim.cmd("silent noautocmd update")
            end)
          end

          local was = before[bufnr]
          if was and not was.visible and not was.listed and vim.fn.bufwinid(bufnr) == -1 then
            pcall(function() vim.bo[bufnr].buflisted = false end)
          end
        end
      end

      return ret
    end
  end
end
