-----------------------
---- LOOK AND FEEL ----
-----------------------

local colors = require("config.colors")

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,

		border_size = 3,

		col = {
			active_border = { colors = { colors.color1, colors.color14 }, angle = 45 },
			inactive_border = { colors = { colors.color0, colors.color8 }, angle = 45 },
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",

		snap = {
			enabled = true,
		},
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 0.85,
		inactive_opacity = 0.7,

		shadow = {
			enabled = true,
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			xray = true,
		},
	},

	group = {
		col = {
			border_active = colors.cachydgreen,
			border_inactive = colors.cachylgreen,
			border_locked_active = colors.cachymgreen,
			border_locked_inactive = colors.cachydblue,
		},

		groupbar = {
			font_family = "Fira Sans",
			text_color = colors.cachydblue,
			col = {
				active = colors.cachydgreen,
				inactive = colors.cachylgreen,
				locked_active = colors.cachymgreen,
				locked_inactive = colors.cachydblue,
			},
		},
	},

	render = {
		direct_scanout = true,
	},

	animations = {
		enabled = true,
	},
})

hl.curve("smoothOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("softOvershot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.04 } } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "softOvershot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "smoothOut" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 5, bezier = "smoothOut", style = "slidefade 20%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5, bezier = "smoothOut", style = "slidefade 20%" })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		special_scale_factor = 0.8,
		preserve_split = true,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
		special_scale_factor = 0.8,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
