vim.keymap.set({ "n", "v" }, ";", ":", { remap = true })
vim.keymap.set("n", "<leader>cb", "<cmd>%bd|e#<cr>")
vim.keymap.set("n", "<leader>ft", "<cmd>FloatermToggle<cr>", { desc = "Terminal (Root Dir)" })
vim.keymap.set("n", "<leader>fT", "<cmd>FloatermToggle<cr>", { desc = "Terminal (cwdr)" })
