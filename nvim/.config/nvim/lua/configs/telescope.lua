local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Open all currently multi-selected entries; fall back to default for single selection.
local function open_multi(prompt_bufnr, open_cmd)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()

  -- If nothing is multi-selected, use Telescope's built-ins
  if vim.tbl_isempty(multi) then
    if open_cmd == "vsplit" then
      return actions.file_vsplit(prompt_bufnr)
    elseif open_cmd == "split" then
      return actions.file_split(prompt_bufnr)
    elseif open_cmd == "tabedit" then
      return actions.file_tab(prompt_bufnr)
    else
      return actions.select_default(prompt_bufnr)
    end
  end

  actions.close(prompt_bufnr)

  for _, entry in pairs(multi) do
    -- Handle various picker entry shapes
    local filename = entry.path or entry.filename or entry.value
    local lnum = entry.lnum
    if filename then
      local cmd = open_cmd or "edit"
      if lnum then
        vim.cmd(string.format("%s +%d %s", cmd, lnum, vim.fn.fnameescape(filename)))
      else
        vim.cmd(string.format("%s %s", cmd, vim.fn.fnameescape(filename)))
      end
    end
  end
end

telescope.setup {
  defaults = {
    -- Filter results: hide VCS directory explicitly
    file_ignore_patterns = { "%.git/", "node_modules", "vendor" },
    mappings = {
      i = {
        ["<CR>"] = function(bufnr)
          open_multi(bufnr, "edit")
        end,
        ["<C-v>"] = function(bufnr)
          open_multi(bufnr, "vsplit")
        end,
        ["<C-x>"] = function(bufnr)
          open_multi(bufnr, "split")
        end,
        ["<C-t>"] = function(bufnr)
          open_multi(bufnr, "tabedit")
        end,
        -- Make multi-select ergonomic
        ["<Tab>"] = function(bufnr)
          actions.toggle_selection(bufnr)
          actions.move_selection_next(bufnr)
        end,
        ["<S-Tab>"] = function(bufnr)
          actions.toggle_selection(bufnr)
          actions.move_selection_previous(bufnr)
        end,
      },
      n = {
        ["<CR>"] = function(bufnr)
          open_multi(bufnr, "edit")
        end,
        ["<C-v>"] = function(bufnr)
          open_multi(bufnr, "vsplit")
        end,
        ["<C-x>"] = function(bufnr)
          open_multi(bufnr, "split")
        end,
        ["<C-t>"] = function(bufnr)
          open_multi(bufnr, "tabedit")
        end,
        ["<Tab>"] = function(bufnr)
          actions.toggle_selection(bufnr)
          actions.move_selection_next(bufnr)
        end,
        ["<S-Tab>"] = function(bufnr)
          actions.toggle_selection(bufnr)
          actions.move_selection_previous(bufnr)
        end,
      },
    },
  },
  pickers = {
    -- Respect .gitignore while still allowing hidden files
    find_files = {
      hidden = true,
    },
    live_grep = {
      additional_args = function()
        return { "--hidden", "--glob=!.git/*" }
      end,
    },
    grep_string = {
      additional_args = function()
        return { "--hidden", "--glob=!.git/*" }
      end,
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {},
    },
  },
}

pcall(telescope.load_extension, "ui-select")
