local auto_session = require "auto-session"

auto_session.setup {
  -- Use current option names per rmagatti/auto-session
  suppressed_dirs = { "~/", "~/Development", "~/Downloads", "/" },
  session_lens = {
    buftypes_to_ignore = {},
    load_on_setup = true,
    picker_opts = { border = true },
  },
}
