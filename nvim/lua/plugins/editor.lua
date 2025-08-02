return {
  -- colour highlighter
  {
    "norcalli/nvim-colorizer.lua",
    lazy = true,
    init = function()
      require("colorizer").setup()
    end,
  },
  -- provides integration with wexzterm multiplexing
  { "mrjones2014/smart-splits.nvim" },
  -- disable neo-tree in favour of the snacks picker
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- shift snacks explorer to appear on right hand side
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            layout = { layout = { position = "right" } },
          },
        },
      },
    },
    keys = {
      {
        "<leader>fe",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (root dir)",
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer()
        end,
        desc = "Explorer Snacks (cwd)",
      },
      { "<leader>e", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
      { "<leader>E", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    },
  },
  -- turn off unused snippet plugins
  {
    "garymjr/nvim-snippets",
    enabled = false,
  },
  { "rafamadriz/friendly-snippets", enabled = false },
  -- tree sitter context
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
      return { mode = "cursor", max_lines = 3 }
    end,
  },
  -- set up harpoon2
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local keys = {
        {
          "<leader>H",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>h",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = "Harpoon Quick Menu",
        },
      }

      for i = 1, 5 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
  },
  -- inlay hints moved to the end of the line rather than being inline
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {},
  },
}
