return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.codebook = opts.servers.codebook or {}
      opts.servers.codebook.filetypes = vim.list_extend(vim.deepcopy(vim.lsp.config.codebook.filetypes), {
        "jjdescription",
      })

      local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
      opts.servers.codebook.handlers = {
        ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
          local bufnr = result and result.uri and vim.uri_to_bufnr(result.uri)
          if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "jjdescription" then
            result.diagnostics = vim.tbl_filter(function(diagnostic)
              local line = vim.api.nvim_buf_get_lines(
                bufnr,
                diagnostic.range.start.line,
                diagnostic.range.start.line + 1,
                false
              )[1]
              return not (line or ""):match("^JJ:")
            end, result.diagnostics)
          end
          publish_diagnostics(err, result, ctx, config)
        end,
      }
    end,
  },
}
