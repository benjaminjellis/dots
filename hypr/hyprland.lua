local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = config_path:match("(.*/)")

package.path = table.concat({
  config_dir .. "?.lua",
  config_dir .. "?/init.lua",
  package.path,
}, ";")

local function load_optional_config(module)
  local ok, result = pcall(require, module)

  if ok then
    if type(result) == "function" then
      result()
    end

    return result
  end

  if result:match("^module '" .. module:gsub("%.", "%%.") .. "' not found:") then
    return nil
  end

  error(result)
end

local apps = require("lua.apps")

require("lua.monitors")()
load_optional_config("source.monitors")
require("lua.settings")()
require("lua.autostart")(apps)
require("lua.binds")(apps)
load_optional_config("source.workspaces")
require("lua.rules")()
