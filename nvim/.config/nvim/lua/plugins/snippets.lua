return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    init = function()
      require("configs.luasnip").init()
    end,
  },
}
