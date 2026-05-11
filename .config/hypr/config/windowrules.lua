--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

local colors = require("config.colors")

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

-- Float necessary windows
hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "^(org.pulseaudio.pavucontrol)" },

	float = true,
})

hl.window_rule({
	name = "float-empty-class-picture-in-picture",
	match = {
		class = "^()$",
		title = "^(Picture in picture)$",
	},

	float = true,
})

hl.window_rule({
	name = "float-save-file",
	match = {
		class = "^()$",
		title = "^(Save File)$",
	},

	float = true,
})

hl.window_rule({
	name = "float-open-file",
	match = {
		class = "^()$",
		title = "^(Open File)$",
	},

	float = true,
})

hl.window_rule({
	name = "float-librewolf-picture-in-picture",
	match = {
		class = "^(LibreWolf)$",
		title = "^(Picture-in-Picture)$",
	},

	float = true,
})

hl.window_rule({
	name = "float-blueman-manager",
	match = { class = "^(blueman-manager)$" },

	float = true,
})

hl.window_rule({
	name = "float-portals",
	match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" },

	float = true,
})

hl.window_rule({
	name = "float-polkit",
	match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" },

	float = true,
})

hl.window_rule({
	name = "float-cachyos-hello",
	match = { class = "^(CachyOSHello)$" },

	float = true,
})

hl.window_rule({
	name = "float-zenity",
	match = { class = "^(zenity)$" },

	float = true,
})

hl.window_rule({
	name = "float-steam-self-updater",
	match = {
		class = "^()$",
		title = "^(Steam - Self Updater)$",
	},

	float = true,
})

-- General floating media/dialog windows
hl.window_rule({
	name = "float-picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },

	float = true,
	size = "960 540",
	move = "25% 25%",
})

hl.window_rule({
	name = "float-media-tools",
	match = { title = "^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$" },

	float = true,
	move = "25% 25%",
	size = "960 540",
})

hl.window_rule({
	name = "pin-danmufloat",
	match = { title = "^(danmufloat)$" },

	pin = true,
})

hl.window_rule({
	name = "round-float-titles",
	match = { title = "^(danmufloat|termfloat)$" },

	rounding = 5,
})

hl.window_rule({
	name = "terminal-slide-animation",
	match = { class = "^(kitty|Alacritty)$" },

	animation = "slide right",
})

hl.window_rule({
	name = "firefox-no-blur",
	match = { class = "^(org.mozilla.firefox)$" },

	no_blur = true,
})

-- Decorations related to floating windows on workspaces 1 to 10
hl.window_rule({
	name = "floating-workspace-border-size",
	match = {
		float = true,
		workspace = "w[fv1-10]",
	},

	border_size = 2,
})

hl.window_rule({
	name = "floating-workspace-border-color",
	match = {
		float = true,
		workspace = "w[fv1-10]",
	},

	border_color = colors.cachylblue,
})

hl.window_rule({
	name = "floating-workspace-rounding",
	match = {
		float = true,
		workspace = "w[fv1-10]",
	},

	rounding = 8,
})

-- Preserved as it was in the old config, including match:float 1.
hl.window_rule({
	name = "workspace-float-border-size",
	match = {
		float = true,
		workspace = "f[1-10]",
	},

	border_size = 3,
})

hl.window_rule({
	name = "workspace-float-rounding",
	match = {
		float = true,
		workspace = "f[1-10]",
	},

	rounding = 4,
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Workspace rules
hl.workspace_rule({
	workspace = "w[tv1-10]",
	gaps_out = 10,
	gaps_in = 5,
})

hl.workspace_rule({
	workspace = "f[1]",
	gaps_out = 10,
	gaps_in = 5,
})

-- Layer rules
hl.layer_rule({
	name = "logout-dialog-slide-top",
	match = { namespace = "logout_dialog" },

	animation = "slide top",
})

hl.layer_rule({
	name = "waybar-slide-down",
	match = { namespace = "waybar" },

	animation = "slide down",
})

hl.layer_rule({
	name = "wallpaper-fade",
	match = { namespace = "wallpaper" },

	animation = "fade 50%",
})
