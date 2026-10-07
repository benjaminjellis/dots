-- Run from the repository root: nvim --headless -u NONE -l nvim/tests/go_lint.lua
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")

local base = vim.fn.tempname()
local calls, notices = {}, {}
local system, notify = vim.system, vim.notify
vim.system = function(args, opts, callback)
  calls[#calls + 1] = { args = args, opts = opts, callback = callback }
end
vim.notify = function(message, _, opts)
  if opts and opts.title == "golangci-lint" then
    notices[#notices + 1] = message
  end
end

local function buffer(path)
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  vim.bo[bufnr].filetype = "go"
  return bufnr
end

local function save(bufnr)
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = bufnr })
end

local function wait_for(predicate)
  assert(vim.wait(2000, predicate, 10), "timed out")
end

local function finish(index, filename, text)
  calls[index].callback({
    code = 0,
    stdout = vim.json.encode({
      Issues = filename and {
        { Pos = { Filename = filename, Line = 3, Column = 2 }, Text = text, FromLinter = "errcheck" },
      } or {},
    }),
  })
end

local ok, err = xpcall(function()
  for _, name in ipairs({ "one", "two" }) do
    vim.fn.mkdir(base .. "/" .. name .. "/pkg", "p")
    vim.fn.writefile({ "module example.com/" .. name, "go 1.23" }, base .. "/" .. name .. "/go.mod")
    vim.fn.writefile({ "package pkg" }, base .. "/" .. name .. "/pkg/other.go")
  end
  base = vim.uv.fs_realpath(base)
  require("config.go_lint").setup()
  local one = buffer(base .. "/one/main.go")
  local two = buffer(base .. "/two/main.go")
  local other = base .. "/one/pkg/other.go"
  local ns = vim.api.nvim_create_namespace("golangci-lint:" .. base .. "/one")
  local function diagnostics()
    return vim.diagnostic.get(nil, { namespace = ns })
  end

  save(one)
  save(one)
  wait_for(function()
    return #calls == 1
  end)
  assert(calls[1].opts.cwd == base .. "/one", vim.inspect(calls[1].opts))
  assert(calls[1].args[#calls[1].args] == "./...")
  finish(1, other, "unchecked error")
  wait_for(function()
    return #diagnostics() == 1
  end)
  local diag = diagnostics()[1]
  assert(diag.lnum == 2 and diag.col == 1 and diag.source == "errcheck")
  assert(diag.severity == vim.diagnostic.severity.WARN)
  assert(not vim.api.nvim_buf_is_loaded(diag.bufnr), "unopened files should stay unloaded")

  save(one)
  wait_for(function()
    return #calls == 2
  end)
  save(one)
  save(one)
  finish(2, other, "stale")
  wait_for(function()
    return #calls == 3
  end)
  assert(diagnostics()[1].message == "unchecked error")
  calls[3].callback({ code = 1, stderr = "broken config" })
  wait_for(function()
    return #notices == 1
  end)
  assert(diagnostics()[1].message == "unchecked error")
  assert(notices[1]:find("broken config", 1, true))

  save(one)
  wait_for(function()
    return #calls == 4
  end)
  calls[4].callback({ code = 0, stdout = "not json" })
  wait_for(function()
    return #notices == 2
  end)
  assert(#diagnostics() == 1)

  save(two)
  wait_for(function()
    return #calls == 5
  end)
  save(one)
  vim.wait(600, function()
    return false
  end)
  assert(#calls == 5, "module scans must be serialized")
  finish(5, base .. "/two/pkg/other.go", "second module")
  wait_for(function()
    return #calls == 6
  end)
  finish(6)
  wait_for(function()
    return #diagnostics() == 0
  end)
  assert(#vim.diagnostic.get() == 1, "clearing one module must preserve another")

  save(buffer(base .. "/standalone.go"))
  local scratch = buffer(base .. "/one/scratch.go")
  vim.bo[scratch].buftype = "nofile"
  save(scratch)
  vim.wait(600, function()
    return false
  end)
  assert(#calls == 6, "standalone and scratch buffers must be skipped")
end, debug.traceback)

vim.system, vim.notify = system, notify
vim.fn.delete(base, "rf")
assert(ok, err)
print("go_lint: passed")
