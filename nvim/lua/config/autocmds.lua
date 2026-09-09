-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- diffview.nvim (and similar: jujutsu.nvim's diff panes, fugitive blobs) load
-- git-object revisions into scratch buffers (buftype ~= "") that still carry a
-- real filetype for syntax highlighting. LSP attaches based on filetype and
-- then chokes on the non-file:// buffer name, e.g.:
--   gopls: -32700: JSON RPC parse error: DocumentURI scheme is not 'file':
--   diffview:///path/.git/:0:/pkg/file.go
-- The working-tree side of a diffview split is a normal editable buffer
-- (buftype == ""), so this only strips LSP from the read-only revision side.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_skip_scratch_buffers", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      vim.schedule(function() pcall(vim.lsp.buf_detach_client, args.buf, args.data.client_id) end)
    end
  end,
})
