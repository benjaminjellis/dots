local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = config_path:match("(.*/)")

package.path = table.concat({
  config_dir .. "?.lua",
  config_dir .. "?/init.lua",
  package.path,
}, ";")

local function require_optional(module)
  local ok, result = pcall(require, module)

  if ok then
    return result
  end

  if result:match("^module '" .. module:gsub("%.", "%%.") .. "' not found:") then
    return nil
  end

  error(result)
end

local apps = require("lua.apps")

require("lua.monitors")()
require_optional("source.monitors")
require("lua.settings")()
require("lua.autostart")(apps)
require("lua.binds")(apps)
require_optional("source.workspaces")
require("lua.rules")()
