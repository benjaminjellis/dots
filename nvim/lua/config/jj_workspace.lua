local M = {}

local cache = {}
local refresh_ms = 5000

function M.status()
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = vim.bo.buftype == "" and buf ~= "" and vim.fn.fnamemodify(buf, ":p:h") or vim.fn.getcwd()
  local root = require("jujutsu.jj.cli").find_workspace_root(dir)
  if not root then
    return ""
  end

  local entry = cache[root]
  if not entry then
    entry = { name = "", updated = -refresh_ms, pending = false }
    cache[root] = entry
  end

  -- Never run a blocking jj command during a statusline redraw.
  if not entry.pending and vim.uv.now() - entry.updated >= refresh_ms then
    entry.pending = true
    local ok = pcall(vim.system, {
      require("jujutsu.jj.shell").resolve_jj(),
      "--ignore-working-copy",
      "--no-pager",
      "--color=never",
      "workspace",
      "list",
      "-T",
      'if(target.current_working_copy(), name ++ "\\n")',
    }, { cwd = root, text = true, timeout = 3000 }, function(result)
      vim.schedule(function()
        entry.name = result.code == 0 and vim.trim(result.stdout or "") or ""
        entry.updated = vim.uv.now()
        entry.pending = false
        if package.loaded["lualine"] then
          require("lualine").refresh({ place = { "statusline" } })
        end
      end)
    end)
    if not ok then
      entry.name = ""
      entry.updated = vim.uv.now()
      entry.pending = false
    end
  end

  -- Workspace names are data, not statusline formatting directives.
  return entry.name ~= "" and ("@" .. entry.name:gsub("%%", "%%%%")) or ""
end

return M
