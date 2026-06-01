require("nvim-ts-autotag").setup {
  opts = {
    enable_close = true, -- auto-close tags
    enable_rename = true, -- rename closing tag when opening tag changes
    enable_close_on_slash = true, -- close tag on </
  },
}
