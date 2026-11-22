return function()
	hl.config({
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
		name = "mechboards-corne-pro-r2g",
		kb_layout = "us",
	})

	hl.device({
		name = "bastard-keyboards-dilemma-(3x5+3)-assembled",
		kb_layout = "us",
	})

	if require("lua.utils").is_neo() then
		hl.device({
			name = "apple-mtp-keyboard",
			kb_layout = "gb",
			kb_variant = "mac",
		})
		hl.device({
			name = "apple-mtp-multi-touch",
			sensitivity = -0.2,
			scroll_factor = 0.4,
		})
	end
end
