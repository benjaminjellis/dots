local M = {}

local function open_jj(root)
  local function jj(args)
    local result = vim.system(vim.list_extend({ "jj", "--color=never", "--no-pager" }, args), {
      cwd = root,
      text = true,
    }):wait()

    if result.code ~= 0 then
      error(vim.trim(result.stderr), 0)
    end

    return result.stdout
  end

  local git_dir = vim.trim(jj({ "git", "root" }))
  local parents = vim.split(vim.trim(jj({ "log", "--no-graph", "-r", "@-", "-T", 'commit_id ++ "\n"' })), "\n")
  if #parents ~= 1 then
    error("This diff currently requires a working copy with one parent.", 0)
  end

  local GitAdapter = require("diffview.vcs.adapters.git").GitAdapter
  local GitRev = require("diffview.vcs.adapters.git.rev").GitRev
  local RevType = require("diffview.vcs.rev").RevType
  local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
  local CustomView = require("diffview.api.views.diff.diff_view").CDiffView
  local adapter = GitAdapter({ toplevel = git_dir })
  adapter.ctx.toplevel = root
  adapter.ctx.dir = git_dir
  adapter.get_command = function()
    return { "git", "--git-dir=" .. git_dir, "--work-tree=" .. root }
  end

  -- jj owns the working copy; never stage into the shared Git index.
  local function no_staging()
    vim.notify("Use jj to manage this working copy; Git staging is disabled.", vim.log.levels.WARN)
    return false
  end
  adapter.add_files = no_staging
  adapter.reset_files = no_staging
  adapter.file_restore = require("diffview.async").wrap(function(_, _, _, _, callback)
    vim.notify("Use jj restore in this workspace.", vim.log.levels.WARN)
    callback(false)
  end)

  local parent = parents[1]
  if parent == string.rep("0", 40) then
    parent = GitRev.NULL_TREE_SHA
  end

  local view = DiffView({
    adapter = adapter,
    left = GitRev(RevType.COMMIT, parent),
    right = GitRev(RevType.LOCAL),
    path_args = {},
    rev_arg = "jj @- → working copy",
  })

  -- Reuse Diffview's custom file-list API, retaining normal LOCAL buffers for LSP.
  view.create_file_entries = CustomView.create_file_entries
  view.get_updated_files = CustomView.get_updated_files
  view.fetch_files = function()
    local output = jj({
      "diff", "--from", parents[1], "--to", "@", "-T",
      'status_char ++ "\\0" ++ path ++ "\\0" ++ source.path() ++ "\\0"',
    })
    local fields = vim.split(output, "\0", { plain = true, trimempty = false })
    local files = {}
    for i = 1, #fields - 1, 3 do
      table.insert(files, { status = fields[i], path = fields[i + 1], oldpath = fields[i + 2] })
    end

    return { working = files }
  end

  require("diffview.lib").add_view(view)
  view:open()
end

function M.open()
  local marker = vim.fs.find(".jj", { path = vim.fn.getcwd(), upward = true })[1]
  if not marker then
    vim.cmd.DiffviewOpen()
    return
  end

  local ok, err = pcall(open_jj, vim.fs.dirname(marker))
  if not ok then
    vim.notify(err, vim.log.levels.ERROR, { title = "Diffview" })
  end
end

return M
