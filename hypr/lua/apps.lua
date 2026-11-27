local is_neo = require("lua.utils").is_neo()

return {
	is_neo = is_neo,
	main_mod = "SUPER",
	terminal = "ghostty",
	browser = "zen-browser",
	personal_browser = 'zen-browser -P "Personal"',
	work_browser = 'zen-browser -P "Work"',
	launcher = "hyprlauncher",
	file_manager = "io.elementary.files",
	bluetooth_manager = "blueman-manager",
	lock = is_neo and "omarchy system lock" or "pidof swaylock || swaylock -f",
	music = "spotify",
	sunset_warmer = "hyprctl hyprsunset temperature -500",
	sunset_cooler = "hyprctl hyprsunset temperature +500",
	vpn_connect = "protonvpn connect --country JP",
	vpn_disconnect = "protonvpn disconnect",
	screenshot_region = "hyprshot -m region",
	neg_py = "QT_SCALE_FACTOR=1.5  ~/Applications/NegPy-0.60.0-x86_64.AppImage",
	screenshot_output = "hyprshot -m output",
	ime_toggle = "sh -c 'fcitx5-remote -t || { fcitx5 -d; sleep 0.2; fcitx5-remote -t; }'",
	autostart = {
		"env DOTS_BAR_BRIGHTNESS=" .. (is_neo and "1" or "0") .. ' quickshell -n -p "$HOME/.config/hypr/bar"',
		"hyprpaper",
		is_neo and 'mkdir -p "$HOME/.local/state/omarchy/toggles"'
			.. ' && touch "$HOME/.local/state/omarchy/toggles/bar-off"'
			.. ' && exec omarchy-launch-shell' or "hypridle",
		"hyprsunset",
		"fcitx5 -d",
		"systemctl --user start hyprpolkitagent",
		"protonvpn-app",
		is_neo and "swaync" or nil,
	},
}
