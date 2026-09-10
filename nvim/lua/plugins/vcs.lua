-- git related plugins
return {
  -- depends on the git extra for highlighting and auto-completion of github issues/prs
  { import = "lazyvim.plugins.extras.lang.git" },
  {
    "clabby/difftastic.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- optional: only needed for :DifftPick
      "folke/snacks.nvim",
    },
    config = function()
      require("difftastic-nvim").setup({
        download = true, -- Auto-download pre-built binary
        -- ]c/[c collide with LazyVim's treesitter-textobjects "class" motion, which
        -- re-attaches on FileType (fired when diff.lua sets filetype for highlighting)
        -- and clobbers difftastic's buffer-local maps. Rebind off ]c/[c to avoid it.
        keymaps = {
          next_hunk = "]h",
          prev_hunk = "[h",
        },
        snacks_picker = {
          enabled = true,
        },
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview (working tree)" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = {},
  },
  {
    "mistweaverco/jujutsu.nvim",
    lazy = true,
    keys = {
      {
        "<leader>jj",
        function()
          require("jujutsu").open()
        end,
        desc = "open jujutsu",
      },
      {
        "<leader>jd",
        function()
          local root = require("jujutsu.jj.cli").find_workspace_root()
          if not root then
            require("jujutsu.notify").error("not a jj workspace")
            return
          end
          require("jujutsu.buffers.editor").open({
            root = root,
            on_submit = function()
              require("jujutsu").refresh()
            end,
          })
        end,
        desc = "jujutsu describe",
      },
      {
        "<leader>jl",
        function()
          local root = require("jujutsu.jj.cli").find_workspace_root()
          if not root then
            require("jujutsu.notify").error("not a jj workspace")
            return
          end
          require("jujutsu.buffers.log_view").open(root)
        end,
        desc = "jujutsu log",
      },
    },
    opts = {
      diff_preset = "difftastic", -- default
      -- The recursive .jj filewatcher retriggers on jj's own working-copy/op-log
      -- writes, causing an infinite refresh loop (jj call -> touches .jj ->
      -- fs_event -> refresh -> jj call -> ...) that pegs the event loop and
      -- makes nvim unresponsive. Disable until upstream fixes the feedback loop.
      filewatcher = { enabled = false },
    },
    config = function(_, opts)
      require("jujutsu").setup(opts)

      -- jujutsu.nvim derives JujutsuLualineBookmark's color from the `Function`
      -- highlight group, which in ns.nvim is just the plain fg color (tan) --
      -- unreadable against lualine_b's orange background. hl.setup() gets
      -- re-run on every ColorScheme event and whenever stat/commit views open,
      -- so wrap it to keep reasserting our override instead of patching once.
      local hl = require("jujutsu.hl")
      local orig_setup = hl.setup
      hl.setup = function(...)
        orig_setup(...)
        vim.api.nvim_set_hl(0, "JujutsuLualineBookmark", { fg = "#062625", bold = true })
      end
      hl.setup()
    end,
  },
  {
    "folke/snacks.nvim",
    keys = { -- disable conflicting keymaps
      { "<leader>gi", false },
      { "<leader>gI", false },
      { "<leader>gp", false },
      { "<leader>gP", false },
      { "<leader>gd", false }, -- diffview.nvim owns this (see below)
    },
  },
  -- Octo
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    event = { { event = "BufReadCmd", pattern = "octo://*" } },
    opts = {
      enable_builtin = true,
      default_to_projects_v2 = true,
      default_merge_method = "squash",
      picker = "telescope",
    },
    keys = {
      { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "List Issues (Octo)" },
      { "<leader>gI", "<cmd>Octo issue search<CR>", desc = "Search Issues (Octo)" },
      { "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },
      { "<leader>gP", "<cmd>Octo pr search<CR>", desc = "Search PRs (Octo)" },
      { "<leader>gr", "<cmd>Octo repo list<CR>", desc = "List Repos (Octo)" },
      { "<leader>gS", "<cmd>Octo search<CR>", desc = "Search (Octo)" },

      { "<localleader>a", "", desc = "+assignee (Octo)", ft = "octo" },
      { "<localleader>c", "", desc = "+comment/code (Octo)", ft = "octo" },
      { "<localleader>l", "", desc = "+label (Octo)", ft = "octo" },
      { "<localleader>i", "", desc = "+issue (Octo)", ft = "octo" },
      { "<localleader>r", "", desc = "+react (Octo)", ft = "octo" },
      { "<localleader>p", "", desc = "+pr (Octo)", ft = "octo" },
      { "<localleader>pr", "", desc = "+rebase (Octo)", ft = "octo" },
      { "<localleader>ps", "", desc = "+squash (Octo)", ft = "octo" },
      { "<localleader>v", "", desc = "+review (Octo)", ft = "octo" },
      { "<localleader>g", "", desc = "+goto_issue (Octo)", ft = "octo" },
      { "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
      { "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },
    },
  },

  -- Octo Picker
  {
    "pwntester/octo.nvim",
    opts = function(_, opts)
      vim.treesitter.language.register("markdown", "octo")
      if LazyVim.has_extra("editor.telescope") then
        opts.picker = "telescope"
      elseif LazyVim.has_extra("editor.fzf") then
        opts.picker = "fzf-lua"
      elseif LazyVim.has_extra("editor.snacks_picker") then
        opts.picker = "snacks"
      else
        LazyVim.error("`octo.nvim` requires `telescope.nvim` or `fzf-lua` or `snacks.nvim`")
      end

      -- Keep some empty windows in sessions
      vim.api.nvim_create_autocmd("ExitPre", {
        group = vim.api.nvim_create_augroup("octo_exit_pre", { clear = true }),
        callback = function(ev)
          local keep = { "octo" }
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.tbl_contains(keep, vim.bo[buf].filetype) then
              vim.bo[buf].buftype = "" -- set buftype to empty to keep the window
            end
          end
        end,
      })
    end,
  },
}
