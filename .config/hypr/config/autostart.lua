-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("aww-daemon")
	hl.exec_cmd("waybar &")
	hl.exec_cmd("waybar -c ~/.config/waybar/config_dp2 &")
	hl.exec_cmd("fcitx5 -d &")
	hl.exec_cmd("mako &")
	hl.exec_cmd("nm-applet --indicator &")
	hl.exec_cmd(
		[[bash -c 'mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob & disown']]
	)
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 &")
	hl.exec_cmd("usr/bin/pypr")
	hl.exec_cmd("idlehandler")
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("qpwgraph -m")
	hl.exec_cmd("ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("qbittorrent")
end)
