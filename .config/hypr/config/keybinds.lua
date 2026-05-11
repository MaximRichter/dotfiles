---------------------
---- KEYBINDINGS ----
---------------------

local defaults = require("config.defaults")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

local function move_and_focus_workspace(workspace)
	hl.dispatch(hl.dsp.window.move({ workspace = workspace }))
	hl.dispatch(hl.dsp.focus({ workspace = workspace }))
end

local function move_and_focus_relative_workspace(delta)
	local workspace = hl.get_active_workspace()
	if workspace == nil then
		return
	end

	move_and_focus_workspace(workspace.id + delta)
end

-- Application and session binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(defaults.terminal))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
	mainMod .. " + SHIFT + Q",
	hl.dsp.exec_cmd(
		[[sh -c 'class=$(hyprctl activewindow -j | jq -r .class); if [ "$class" = "steam" ]; then pkill -9 -f steam; else kill -9 $(hyprctl activewindow -j | jq -r .pid); fi']]
	)
)
hl.bind(mainMod .. " + CONTROL + SHIFT + M", hl.dsp.exec_cmd([[loginctl terminate-user ""]]))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(defaults.fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(defaults.browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("vesktop"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("emacs"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(defaults.pypr .. " toggle tg"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(defaults.capturing))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Q", hl.dsp.exec_cmd("~/.config/rofi/powermenu/type-1/powermenu.sh"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(defaults.menu))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + y", hl.dsp.window.pin())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waypaper --folder ~/wallpapers/"))
hl.bind(mainMod .. " + CONTROL + R", hl.dsp.exec_cmd("wallpaper-rotation-toggle.sh"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("wal-toggle.sh"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("/opt/yandex-music/yandexmusic"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper --folder ~/wallpapers/ --random"))
hl.bind(mainMod .. " + CONTROL + W", hl.dsp.exec_cmd("wallpaper-picker.sh"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.local/scripts/vpn-picker.sh"))
hl.bind(mainMod .. " + CONTROL + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("gnome-calculator"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("~/.local/scripts/waybar-restart.sh"))
hl.bind(
	mainMod .. " + CONTROL + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)

-- Special workspace from the Lua example
hl.bind(mainMod .. " + CONTROL + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + CONTROL + SHIFT + s", hl.dsp.window.move({ workspace = "special:magic" }))

-- Grouping windows
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Tab", hl.dsp.group.next())
hl.bind(
	mainMod .. " + SHIFT + G",
	hl.dsp.exec_cmd([[hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"]])
)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move active windows with mainMod + Shift + vim keys
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Window resize mode
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
	hl.bind("left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
	hl.bind("l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
	hl.bind("h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Quick resize window with keyboard
hl.bind(mainMod .. " + CONTROL + SHIFT + right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind(mainMod .. " + CONTROL + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT/CONTROL + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	local workspace = i
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
	hl.bind(mainMod .. " + CONTROL + " .. key, function()
		move_and_focus_workspace(workspace)
	end)
end

-- Scroll through workspaces
hl.bind(mainMod .. " + PERIOD", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + COMMA", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + slash", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + CONTROL + left", function()
	move_and_focus_relative_workspace(-1)
end)
hl.bind(mainMod .. " + CONTROL + right", function()
	move_and_focus_relative_workspace(1)
end)

-- Utilities
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd("pkill hyprsunset || hyprsunset -t 4250"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd(defaults.pypr .. " toggle term"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd(defaults.pypr .. " toggle mail"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd(defaults.pypr .. " zoom"))
hl.bind(
	mainMod .. " + C",
	hl.dsp.exec_cmd(
		[[bash -c 'cliphist list | rofi -dmenu -theme ~/.config/rofi/launchers/type-4/style-9.rasi | cliphist decode | wl-copy']]
	)
)
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + SHIFT + slash", hl.dsp.exec_cmd("keybinds-cheatsheet.sh"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		[[bash -c "pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>100) system(\"pactl set-sink-volume @DEFAULT_SINK@ 100%\")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"]]
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		[[bash -c "pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"]]
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(
		[[bash -c "amixer sset Master toggle | sed -En '/\[on\]/ s/.*\[([0-9]+)%\].*/\1/ p; /\[off\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"]]
	),
	{ locked = true, repeating = true }
)
local toggleMicCommand =
	[=[bash -c 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; pkill -RTMIN+11 waybar; v=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@); [[ $v == *MUTED* ]] && notify-send "Mic" " Muted" -t 1500 || notify-send "Mic" " Active" -t 1500']=]
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(toggleMicCommand), { locked = true, repeating = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(toggleMicCommand))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.config({
	binds = {
		allow_workspace_cycles = true,
		workspace_back_and_forth = true,
		workspace_center_on = true,
		movefocus_cycles_fullscreen = true,
		window_direction_monitor_fallback = true,
	},
})
