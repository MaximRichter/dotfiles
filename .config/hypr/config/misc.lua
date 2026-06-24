----------------
----  MISC  ----
----------------

local colors = require("config.colors")

hl.config({
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		font_family = "IBM Plex Sans",
		splash_font_family = "IBM Plex Sans",
		disable_hyprland_logo = true,
		col = {
			splash = colors.cachylgreen,
		},
		background_color = colors.cachydblue,
		enable_swallow = true,
		swallow_regex = "^(cachy-browser|firefox|nautilus|nemo|thunar|btrfs-assistant.)$",
		focus_on_activate = false,
		vrr = 2,
	},
})
