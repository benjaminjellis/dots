-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.swapfile = false
vim.g.snacks_animate = false

-- Prevent LSP clients from attaching to buffers that aren't real files on disk
-- (diffview.nvim / jujutsu.nvim diff panes, fugitive/octo virtual buffers, ...).
-- Neovim's native LSP autostart (lsp_enable_callback) guards on buftype ~= "",
-- but diffview.nvim sets a buffer's name (ending in e.g. ".go") before it marks
-- the buffer non-editable, so autostart can race ahead of that guard and attach
-- while buftype is still "". gopls then fails to even parse the resulting
-- didOpen notification:
--   gopls: -32700: JSON RPC parse error: DocumentURI scheme is not 'file':
--   diffview:///path/.git/:0:/pkg/file.go
-- Filtering on the buffer name instead closes the race: diffview sets the name
-- before anything else, and a real filesystem path never contains "scheme://".
-- Must be patched here (before lazy.nvim starts plugins / autostart can fire).
local lsp_start = vim.lsp.start
vim.lsp.start = function(config, opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name:match("^%a[%w+.-]*://") and not name:match("^file://") then
    return nil
  end
  return lsp_start(config, opts)
end
