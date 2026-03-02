return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "clojure", "edn" },
      root = { "project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", "bb.edn" },
    })
  end,

  -- Add Clojure & related to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "clojure" } },
  },

  -- Extend auto completion
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      "PaterJason/cmp-conjure",
    },
    opts = function(_, opts)
      if type(opts.sources) == "table" then
        vim.list_extend(opts.sources, { name = "conjure" })
      end
    end,
  },

  -- Add s-exp mappings
  { "julienvincent/nvim-paredit", opts = {}, event = "LazyFile" },

  -- Colorize the output of the log buffer
  {
    "m00qek/baleia.nvim",
    opts = {
      line_starts_at = 3,
    },
    config = function(_, opts)
      vim.g.conjure_baleia = require("baleia").setup(opts)

      vim.api.nvim_create_user_command("BaleiaColorize", function()
        vim.g.conjure_baleia.once(vim.api.nvim_get_current_buf())
      end, { bang = true })

      vim.api.nvim_create_user_command("BaleiaLogs", vim.g.conjure_baleia.logger.show, { bang = true })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clojure_lsp = {},
      },
    },
  },
}
