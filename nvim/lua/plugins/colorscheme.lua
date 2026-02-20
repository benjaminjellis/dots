return {
  { "benjaminjellis/ns.nvim", name = "ns" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
    priority = 1000,
    init = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ns",
    },
  },
}
