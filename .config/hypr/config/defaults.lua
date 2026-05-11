return {
	terminal = "ghostty",
	fileManager = "thunar",
	menu = "~/.config/rofi/launchers/type-4/launcher.sh",
	browser = "qutebrowser",
	pypr = "/usr/bin/pypr",
	capturing = [[grim -g "$(slurp)" - | swappy -f -]],
}
