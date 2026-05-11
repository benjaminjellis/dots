return function()
	hl.env("GDK_SCALE", "1.5")
	hl.env("XCURSOR_SIZE", "24")
	hl.env("HYPRCURSOR_SIZE", "24")

	hl.config({
		xwayland = {
			force_zero_scaling = true,
		},
		cursor = {
			no_hardware_cursors = true,
		},
		general = {
			gaps_in = 5,
			gaps_out = 10,
			border_size = 4,
			col = {
				active_border = "rgba(03fcb1aa)",
				inactive_border = "rgba(00000000)",
			},
			resize_on_border = true,
			allow_tearing = false,
			layout = "dwindle",
		},
		decoration = {
			rounding = 10,
			active_opacity = 0.9,
			inactive_opacity = 0.9,
			shadow = {
				enabled = true,
				range = 5,
				render_power = 3,
				color = "rgba(1a1a1aee)",
			},
			blur = {
				enabled = true,
				size = 3,
				passes = 1,
				vibrancy = 0.1696,
			},
		},
		debug = {
			disable_logs = false,
			enable_stdout_logs = false,
		},
		animations = {
			enabled = true,
		},
		dwindle = {
			preserve_split = true,
		},
		master = {
			new_status = "master",
		},
		misc = {
			force_default_wallpaper = 1,
			disable_hyprland_logo = true,
		},
		input = {
			kb_layout = "gb",
			kb_options = "ctrl:nocaps",
			kb_variant = "",
			kb_model = "",
			kb_rules = "",
			follow_mouse = 1,
			sensitivity = -0.1,
			repeat_delay = 300,
			repeat_rate = 50,
			natural_scroll = true,
			touchpad = {
				natural_scroll = true,
				tap_to_click = false,
				clickfinger_behavior = true,
			},
		},
	})

	hl.device({
		name = "bastard-keyboards-dilemma-(3x5+3)-assembled",
		kb_layout = "us",
	})

	hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
	hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
	hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
	hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
	hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

	hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
	hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
	hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
	hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
	hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
	hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
	hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
	hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
	hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
	hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
	hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
	hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
	hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
	hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
	hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
	hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
end
