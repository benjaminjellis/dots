vim.keymap.set({ "n", "v" }, ";", ":", { remap = true })
vim.keymap.set("n", "<leader>cb", "<cmd>%bd|e#<cr>")

local function focus_window(direction)
  vim.cmd.wincmd(direction)
end

local function set_window_nav_keymaps()
  vim.keymap.set("n", "<C-h>", function()
    focus_window("h")
  end, { desc = "Go to Left Window" })
  vim.keymap.set("n", "<C-j>", function()
    focus_window("j")
  end, { desc = "Go to Lower Window" })
  vim.keymap.set("n", "<C-k>", function()
    focus_window("k")
  end, { desc = "Go to Upper Window" })
  vim.keymap.set("n", "<C-l>", function()
    focus_window("l")
  end, { desc = "Go to Right Window" })
end

vim.schedule(set_window_nav_keymaps)
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    vim.schedule(set_window_nav_keymaps)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  desc = "Use consistent window navigation in explorer buffers",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    if filetype ~= "neo-tree" and filetype ~= "snacks_picker_list" and filetype ~= "snacks_picker_input" then
      return
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      local opts = { buffer = args.buf, silent = true, nowait = true }
      vim.keymap.set("n", "<C-h>", function()
        focus_window("h")
      end, vim.tbl_extend("force", opts, { desc = "Go to Left Window" }))
      vim.keymap.set("n", "<BS>", function()
        focus_window("h")
      end, vim.tbl_extend("force", opts, { desc = "Go to Left Window" }))
      vim.keymap.set("n", "<C-l>", function()
        focus_window("l")
      end, vim.tbl_extend("force", opts, { desc = "Go to Right Window" }))
    end)
  end,
})

-- invert default set up for grep search and fuzzy file find
vim.keymap.set("n", "<leader>sg", LazyVim.pick("live_grep", { desc = "Grep (workspace)", root = false }))
vim.keymap.set("n", "<leader>sG", LazyVim.pick("live_grep", { desc = "Grep (crate)", root = true }))

vim.keymap.set("n", "<leader>ff", LazyVim.pick("files", { desc = "Find files (workspace)", root = false }))
vim.keymap.set("n", "<leader>fF", LazyVim.pick("files", { desc = "Find files (crate)", root = true }))
