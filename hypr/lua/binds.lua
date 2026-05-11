local function bind_exec(keys, command, opts)
	hl.bind(keys, hl.dsp.exec_cmd(command), opts)
end

return function(apps)
	local main_mod = apps.main_mod

	bind_exec(main_mod .. " + T", apps.terminal)
	bind_exec(main_mod .. " + O", apps.bluetooth_manager)
	hl.bind(main_mod .. " + Q", hl.dsp.window.kill())
	bind_exec(main_mod .. " + B", apps.personal_browser)
	bind_exec(main_mod .. " + W", apps.work_browser)
	hl.bind(main_mod .. " + ~", hl.dsp.exit())
	bind_exec(main_mod .. " + F", apps.file_manager)
	bind_exec(main_mod .. " + space", apps.launcher)
	bind_exec(main_mod .. " + Z", apps.lock)
	hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
	bind_exec(main_mod .. " + S", apps.music)
	bind_exec(main_mod .. " + N", apps.sunset_warmer)
	bind_exec(main_mod .. " + V", apps.vpn_connect)
	bind_exec(main_mod .. " + SHIFT + V", apps.vpn_disconnect)
	bind_exec(main_mod .. " + SHIFT + N", apps.sunset_cooler)
	bind_exec(main_mod .. " + Print", apps.screenshot_region)
	bind_exec(main_mod .. " + SHIFT + Print", apps.screenshot_output)

	hl.bind(main_mod .. " + Tab", hl.dsp.window.cycle_next())
	hl.bind(main_mod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))

	hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "l" }))
	hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "d" }))
	hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "u" }))
	hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "r" }))

	for workspace = 1, 10 do
		local key = workspace % 10

		hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
		hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
	end

	hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

	hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
	hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

	bind_exec("XF86AudioRaiseVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", { locked = true, repeating = true })
	bind_exec("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", { locked = true, repeating = true })
	bind_exec("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true, repeating = true })
	bind_exec("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true, repeating = true })
	bind_exec("XF86MonBrightnessUp", "brightnessctl s 10%+", { locked = true, repeating = true })
	bind_exec("XF86MonBrightnessDown", "brightnessctl s 10%-", { locked = true, repeating = true })

	bind_exec("XF86AudioNext", "playerctl next", { locked = true })
	bind_exec("XF86AudioPause", "playerctl play-pause", { locked = true })
	bind_exec("XF86AudioPlay", "playerctl play-pause", { locked = true })
	bind_exec("XF86AudioPrev", "playerctl previous", { locked = true })
end
