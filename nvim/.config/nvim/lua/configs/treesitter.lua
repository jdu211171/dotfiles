return {
  -- (If you have auto-session or other plugins here, leave them as they are)
  
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Keep NvChad's default treesitter settings, but override the indent behavior
      opts.indent = opts.indent or { enable = true }
      opts.indent.disable = { "tsx", "typescript" }
    end,
  },
}
