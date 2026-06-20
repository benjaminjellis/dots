vim.keymap.set({ "n", "v" }, ";", ":", { remap = true })
vim.keymap.set("n", "<leader>cb", "<cmd>%bd|e#<cr>")

-- invert default set up for grep search and fuzzy file find
vim.keymap.set("n", "<leader>sg", LazyVim.pick("live_grep", { desc = "Grep (workspace)", root = false }))
vim.keymap.set("n", "<leader>sG", LazyVim.pick("live_grep", { desc = "Grep (crate)", root = true }))

vim.keymap.set("n", "<leader>ff", LazyVim.pick("files", { desc = "Find files (workspace)", root = false }))
vim.keymap.set("n", "<leader>fF", LazyVim.pick("files", { desc = "Find files (crate)", root = true }))

-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
-- moving between splits
-- floating windows (e.g. snacks explorer) don't play well with smart-splits'
-- wincmd navigation, so jump to the previous non-floating window instead
local function move_or_escape_float(move_fn)
  return function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      local prev = vim.fn.win_getid(vim.fn.winnr("#"))
      if prev ~= 0 and vim.api.nvim_win_get_config(prev).relative == "" then
        vim.api.nvim_set_current_win(prev)
        return
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      return
    end
    move_fn()
  end
end
vim.keymap.set("n", "<C-h>", move_or_escape_float(require("smart-splits").move_cursor_left))
vim.keymap.set("n", "<C-j>", move_or_escape_float(require("smart-splits").move_cursor_down))
vim.keymap.set("n", "<C-k>", move_or_escape_float(require("smart-splits").move_cursor_up))
vim.keymap.set("n", "<C-l>", move_or_escape_float(require("smart-splits").move_cursor_right))
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
