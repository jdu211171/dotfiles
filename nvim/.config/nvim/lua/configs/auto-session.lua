local auto_session = require "auto-session"

auto_session.setup {
  -- Use current option names per rmagatti/auto-session
  -- Avoid automatically restoring a previous session when starting with
  -- no arguments. This prevents a stray window from flashing on top of
  -- the dashboard on first start; sessions can still be restored via
  -- Telescope Session Lens (<leader>ls) or :SessionRestore.
  auto_restore_enabled = false,
  suppressed_dirs = { "~/", "~/Development", "~/Downloads", "/" },
  session_lens = {
    buftypes_to_ignore = {},
    load_on_setup = true,
    picker_opts = { border = true },
  },
}
