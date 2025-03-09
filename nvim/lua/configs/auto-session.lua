local auto_session = require("auto-session")

auto_session.setup({
  auto_session_suppress_dirs = { "~/", "~/Development", "~/Downloads", "/" },
  session_lens = {
    buftypes_to_ignore = {},
    load_on_setup = true,
    theme_conf = { border = true },
    preveiwer = false,
  },
})


vim.keymap.set("n", "<leader>ls", require("auto-session.session-lens").search_session, {
  noremap = true,
  desc = "Search session"
})

