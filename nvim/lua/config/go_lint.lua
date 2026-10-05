local M = {}

local projects = {}
local running = false
local pump

local severities = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  refactor = vim.diagnostic.severity.INFO,
  convention = vim.diagnostic.severity.HINT,
}

local function report(root, message)
  vim.notify(root .. ": " .. message, vim.log.levels.WARN, { title = "golangci-lint" })
end

local function decode(output, root)
  local decoded = vim.json.decode(output)
  assert(type(decoded) == "table", "invalid JSON result")
  local issues = decoded.Issues
  if issues == nil or issues == vim.NIL then
    issues = {}
  end
  assert(type(issues) == "table", "invalid Issues result")

  local files = {}
  for _, issue in ipairs(issues) do
    local pos = issue.Pos
    assert(type(pos.Filename) == "string" and pos.Filename ~= "", "missing issue filename")
    local filename = pos.Filename
    if filename:sub(1, 1) ~= "/" then
      filename = root .. "/" .. filename
    end
    filename = vim.fs.normalize(filename)
    files[filename] = files[filename] or {}
    table.insert(files[filename], {
      lnum = math.max(pos.Line - 1, 0),
      col = math.max(pos.Column - 1, 0),
      severity = severities[issue.Severity] or vim.diagnostic.severity.WARN,
      source = issue.FromLinter,
      message = assert(issue.Text, "missing issue text"),
    })
  end
  return files
end

local function publish(project, files)
  local buffers = {}
  for filename, diagnostics in pairs(files) do
    local bufnr = vim.fn.bufadd(filename)
    buffers[bufnr] = true
    vim.diagnostic.set(project.namespace, bufnr, diagnostics)
  end
  for bufnr in pairs(project.buffers) do
    if not buffers[bufnr] and vim.api.nvim_buf_is_valid(bufnr) then
      vim.diagnostic.reset(project.namespace, bufnr)
    end
  end
  project.buffers = buffers
end

local function command()
  local args = {
    "golangci-lint",
    "run",
    "--output.json.path=stdout",
    "--path-mode=abs",
    "--issues-exit-code=0",
    "--show-stats=false",
    "--fix=false",
    "--allow-serial-runners",
  }
  for _, format in ipairs({ "text", "tab", "html", "checkstyle", "code-climate", "junit-xml", "teamcity", "sarif" }) do
    table.insert(args, "--output." .. format .. ".path=")
  end
  table.insert(args, "./...")
  return args
end

pump = function()
  if running then
    return
  end
  for root, project in pairs(projects) do
    if project.ready then
      project.ready = false
      running = true
      local revision = project.revision

      local function finish(result)
        running = false
        if revision == project.revision then
          if result.code ~= 0 then
            report(
              root,
              vim.trim(result.stderr or "") ~= "" and vim.trim(result.stderr)
                or "scan failed (exit " .. result.code .. ")"
            )
          else
            local ok, files = pcall(decode, result.stdout or "", root)
            if ok then
              publish(project, files)
            else
              report(root, "invalid lint output: " .. tostring(files))
            end
          end
        end
        pump()
      end

      local ok, err =
        pcall(vim.system, command(), { cwd = root, text = true, timeout = 120000 }, vim.schedule_wrap(finish))
      if not ok then
        finish({ code = -1, stderr = tostring(err) })
      end
      return
    end
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("go_project_lint", { clear = true }),
    callback = function(event)
      if vim.bo[event.buf].filetype ~= "go" or vim.bo[event.buf].buftype ~= "" then
        return
      end
      local filename = vim.api.nvim_buf_get_name(event.buf)
      if filename == "" then
        return
      end
      local root = vim.fs.root(filename, "go.mod")
      if not root then
        return
      end
      local project = projects[root]
      if not project then
        project = { revision = 0, buffers = {}, namespace = vim.api.nvim_create_namespace("golangci-lint:" .. root) }
        projects[root] = project
      end
      project.revision = project.revision + 1
      project.ready = false
      local revision = project.revision
      vim.defer_fn(function()
        if revision == project.revision then
          project.ready = true
          pump()
        end
      end, 500)
    end,
  })
end

return M
