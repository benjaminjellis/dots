vim.keymap.set({ "n", "v" }, ";", ":", { remap = true })
vim.keymap.set("n", "<leader>cb", "<cmd>%bd|e#<cr>")

-- invert default set up for grep search and fuzzy file find
vim.keymap.set("n", "<leader>sg", LazyVim.pick("live_grep", { desc = "Grep (workspace)", root = false }))
vim.keymap.set("n", "<leader>sG", LazyVim.pick("live_grep", { desc = "Grep (crate)", root = true }))

vim.keymap.set("n", "<leader>ff", LazyVim.pick("files", { desc = "Find files (workspace)", root = false }))
vim.keymap.set("n", "<leader>fF", LazyVim.pick("files", { desc = "Find files (crate)", root = true }))
