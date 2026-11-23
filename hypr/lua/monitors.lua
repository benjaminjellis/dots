local host = require("lua.utils")

if host.is_neo() then
	return function()
		-- The Neo's native mode does not divide evenly at fractional scales.
		hl.config({ debug = { disable_scale_checks = true } })
		hl.monitor({ output = "eDP-1", scale = 1.6 })
	end
elseif host.is_host("axlotl") then
	return function()
		hl.monitor({
			output = "DP-1",
			mode = "preferred",
			position = "1298x670@",
			scale = "1.5",
		})

		hl.monitor({
			output = "HDMI-A-1",
			mode = "preferred",
			position = "0x0",
			scale = "1.67",
			transform = 1,
		})
	end
else
	return function() end
end
