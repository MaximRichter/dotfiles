#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/launchers/type-4/style-9.rasi"
FG=$(grep "^foreground=" ~/.cache/wal/colors.sh 2>/dev/null | cut -d"'" -f2)
DIM=$(grep "^color7=" ~/.cache/wal/colors.sh 2>/dev/null | cut -d"'" -f2)
[ -z "$FG" ]  && FG="#ffffff"
[ -z "$DIM" ] && DIM="#666666"

generate_from_lua() {
    lua <<'LUA'
local home = os.getenv("HOME")
local config_dir = home .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

local records = {}
local current_submap = nil

local function serialize(value)
	if type(value) ~= "table" then
		return tostring(value)
	end

	local parts = {}
	for key, item in pairs(value) do
		parts[#parts + 1] = tostring(key) .. "=" .. serialize(item)
	end
	table.sort(parts)
	return table.concat(parts, ", ")
end

local function command_desc(command)
	local exact = {
		["vesktop"] = "launch Vesktop",
		["emacs"] = "launch Emacs",
		["obsidian"] = "launch Obsidian",
		["gnome-calculator"] = "launch calculator",
		["hyprpicker -a"] = "pick color",
		["hyprlock"] = "lock screen",
		["wallpaper-rotation-toggle.sh"] = "toggle wallpaper rotation",
		["wallpaper-picker.sh"] = "pick wallpaper",
		["wal-toggle.sh"] = "toggle pywal theme",
		["waypaper --folder ~/wallpapers/"] = "open Waypaper",
		["waypaper --folder ~/wallpapers/ --random"] = "random wallpaper",
		["~/.local/scripts/vpn-picker.sh"] = "open VPN picker",
		["~/.local/scripts/waybar-restart.sh"] = "restart Waybar",
		["keybinds-cheatsheet.sh"] = "show keybind cheatsheet",
		["brightnessctl s +5%"] = "brightness up",
		["brightnessctl s 5%-"] = "brightness down",
		["playerctl next"] = "next media track",
		["playerctl play-pause"] = "play/pause media",
		["playerctl previous"] = "previous media track",
	}
	if exact[command] then
		return exact[command]
	end

	if command:match("grim") and command:match("swappy") then
		return "take screenshot"
	elseif command:match("rofi.*/launcher%.sh") then
		return "open app launcher"
	elseif command:match("rofi.*/powermenu") then
		return "open power menu"
	elseif command:match("cliphist") then
		return "open clipboard history"
	elseif command:match("hyprsunset") then
		return "toggle night light"
	elseif command:match("pypr.*toggle term") then
		return "toggle terminal scratchpad"
	elseif command:match("pypr.*toggle mail") then
		return "toggle mail scratchpad"
	elseif command:match("pypr.*toggle tg") then
		return "toggle Telegram scratchpad"
	elseif command:match("pypr.*zoom") then
		return "toggle Pyprland zoom"
	elseif command:match("yandexmusic") then
		return "launch Yandex Music"
	elseif command:match("pactl set%-sink%-volume.*%+5%%") then
		return "volume up"
	elseif command:match("pactl set%-sink%-volume.*%-5%%") then
		return "volume down"
	elseif command:match("amixer sset Master toggle") then
		return "mute volume"
	elseif command:match("wpctl set%-mute") then
		return "toggle microphone mute"
	elseif command:match("terminate%-user") then
		return "terminate user session"
	elseif command:match("hyprshutdown") or command:match("hyprctl dispatch exit") then
		return "exit Hyprland"
	elseif command:match("activewindow") and command:match("kill") then
		return "force close active window"
	end

	return "run: " .. command
end

local function table_value(args, key)
	if type(args[1]) == "table" then
		return args[1][key]
	end
	return nil
end

local function action_desc(action, combo)
	if type(action) == "function" then
		local workspace_key = combo:match("SUPER %+ CONTROL %+ (%d+)$")
		if workspace_key then
			local workspace = tonumber(workspace_key)
			if workspace == 0 then
				workspace = 10
			end
			return "move window and focus workspace " .. workspace
		elseif combo == "SUPER + CONTROL + left" then
			return "move window and focus previous workspace"
		elseif combo == "SUPER + CONTROL + right" then
			return "move window and focus next workspace"
		end
		return "custom Lua action"
	elseif type(action) ~= "table" then
		return tostring(action)
	end

	local path = action.path
	local args = action.args or {}

	if path == "exec_cmd" then
		return command_desc(tostring(args[1]))
	elseif path == "window.close" then
		return "close active window"
	elseif path == "window.float" then
		return "toggle floating window"
	elseif path == "window.fullscreen" then
		return "toggle fullscreen"
	elseif path == "window.pin" then
		return "pin active window"
	elseif path == "window.pseudo" then
		return "toggle pseudotiling"
	elseif path == "window.drag" then
		return "drag window"
	elseif path == "window.resize" then
		local direction = table_value(args, "direction")
		if direction then
			return "move window " .. direction
		end
		return "resize window"
	elseif path == "window.move" then
		local direction = table_value(args, "direction")
		local workspace = table_value(args, "workspace")
		if direction then
			return "move window " .. direction
		elseif workspace then
			return "move window to workspace " .. workspace
		end
		return "move window"
	elseif path == "focus" then
		local direction = table_value(args, "direction")
		local workspace = table_value(args, "workspace")
		if direction then
			return "focus " .. direction
		elseif workspace then
			return "focus workspace " .. workspace
		end
		return "change focus"
	elseif path == "layout" then
		return "layout: " .. tostring(args[1])
	elseif path == "submap" then
		return "enter " .. tostring(args[1]) .. " mode"
	elseif path == "workspace.toggle_special" then
		return "toggle special workspace " .. tostring(args[1])
	elseif path == "group.toggle" then
		return "toggle window group"
	elseif path == "group.next" then
		return "focus next grouped window"
	end

	if #args > 0 then
		return path .. " (" .. serialize(args[1]) .. ")"
	end
	return path
end

local function proxy(path)
	return setmetatable({}, {
		__index = function(_, key)
			local next_path = path == "" and key or path .. "." .. key
			return proxy(next_path)
		end,
		__call = function(_, ...)
			return { path = path, args = { ... } }
		end,
	})
end

hl = {
	dsp = proxy(""),
	bind = function(combo, action, opts)
		opts = opts or {}
		local prefix = current_submap and ("[" .. current_submap .. "] ") or ""
		records[#records + 1] = {
			combo = prefix .. tostring(combo),
			desc = action_desc(action, tostring(combo)),
			mouse = opts.mouse == true,
		}
		return { set_enabled = function() end }
	end,
	define_submap = function(name, fn)
		local previous = current_submap
		current_submap = name
		fn()
		current_submap = previous
	end,
	config = function() end,
	dispatch = function() end,
	get_active_workspace = function()
		return { id = 1 }
	end,
}

require("config.keybinds")

for _, record in ipairs(records) do
	local combo = record.combo
		:gsub("SUPER", "Super")
		:gsub("CONTROL", "Ctrl")
		:gsub("SHIFT", "Shift")
		:gsub("RETURN", "Enter")
		:gsub("SPACE", "Space")
		:gsub("PERIOD", ".")
		:gsub("COMMA", ",")
		:gsub("slash", "/")
		:gsub("mouse:272", "LMB")
		:gsub("mouse:273", "RMB")
	print(combo .. "\t" .. record.desc)
end
LUA
}

generate_from_legacy_conf() {
    grep "^bindd" "$HOME/.config/hypr/config/keybinds.conf" 2>/dev/null | \
        awk -F', ' '{
            mods=$1; key=$2; desc=$3
            sub(/^bindd = /, "", mods)
            gsub(/\$mainMod/, "Super", mods)
            print mods " + " key "\t" desc
        }'
}

if [ -f "$HOME/.config/hypr/config/keybinds.lua" ]; then
    keybinds=$(generate_from_lua)
else
    keybinds=$(generate_from_legacy_conf)
fi

printf '%s\n' "$keybinds" | \
    awk -F'\t' -v fg="$FG" -v dim="$DIM" 'NF >= 2 {
        printf "<span foreground=\"%s\" weight=\"bold\">%-33s</span>  <span foreground=\"%s\">%s</span>\n", fg, $1, dim, $2
    }' | \
    rofi -dmenu -p " Keybinds" -theme "$ROFI_THEME" -no-custom -i -markup-rows \
         -theme-str 'window {width: 85%; height: 75%;} listview {columns: 3; lines: 20;}'
