return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "mond",
        callback = function(args)
          vim.bo[args.buf].commentstring = ";; %s"
          pcall(vim.treesitter.start, args.buf, "mond")
        end,
      })
      return opts
    end,
  },
  -- turn off auto insert of () on accepting a completion
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        accept = {
          auto_brackets = {
            override_brackets_for_filetypes = {
              mond = { "", "" },
            },
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mond = {
          cmd = { "bahn", "lsp" },
          filetypes = { "mond" },
          root_markers = { "mond.toml", ".git" },
        },
      },
    },
  },
}
