return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        racket_langserver = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "racket",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        racket = { "racketfmt" },
      },
    },
  },
}
