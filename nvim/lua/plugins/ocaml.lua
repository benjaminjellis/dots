local has_ocaml = vim.fn.executable("opam") == 1

return {
  {
    "tarides/ocaml.nvim",
    enabled = has_ocaml,
    config = function()
      require("ocaml").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not has_ocaml then
        return
      end

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
    opts = function(_, opts)
      if not has_ocaml then
        return
      end

      opts.servers = opts.servers or {}
      opts.servers.ocamllsp = {
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
      }
    end,
  },
}
