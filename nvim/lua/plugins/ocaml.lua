return {
  {
    "tarides/ocaml.nvim",
    config = function()
      require("ocaml").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "ocaml" })
        opts.indent = opts.indent or {}
        opts.indent.enable = true
        opts.indent.disable = opts.indent.disable or {}
        table.insert(opts.indent.disable, "ocaml")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {
          filetypes = {
            "ocaml",
            "ocaml.menhir",
            "ocaml.interface",
            "ocaml.ocamllex",
            "reason",
            "dune",
          },
          root_markers = {
            function(name)
              return name:match(".*%.opam$")
            end,
            "esy.json",
            "package.json",
            ".git",
            "dune-project",
            "dune-workspace",
            function(name)
              return name:match(".*%.ml$")
            end,
          },
        },
      },
    },
  },
}
