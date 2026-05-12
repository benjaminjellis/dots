local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = config_path:match("(.*/)")

package.path = table.concat({
  config_dir .. "?.lua",
  config_dir .. "?/init.lua",
  package.path,
}, ";")

local apps = require("lua.apps")

require("lua.monitors")()
require("lua.settings")()
require("lua.autostart")(apps)
require("lua.binds")(apps)
require("lua.workspaces")()
require("lua.rules")()
