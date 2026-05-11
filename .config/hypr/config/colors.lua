local colors = {
	background = "rgb(101e21)",
	foreground = "rgb(c3c6c7)",
	bg = "rgb(101e21)",
	fg = "rgb(c3c6c7)",

	color0 = "rgb(101e21)",
	color1 = "rgb(7b6c48)",
	color2 = "rgb(95774e)",
	color3 = "rgb(255c64)",
	color4 = "rgb(258172)",
	color5 = "rgb(477c71)",
	color6 = "rgb(829081)",
	color7 = "rgb(91999c)",
	color8 = "rgb(5e6f72)",
	color9 = "rgb(a49160)",
	color10 = "rgb(c79f68)",
	color11 = "rgb(327b86)",
	color12 = "rgb(32ad98)",
	color13 = "rgb(5fa697)",
	color14 = "rgb(aec0ac)",
	color15 = "rgb(c3c6c7)",

	cachylgreen = "rgba(82dcccff)",
	cachymgreen = "rgba(00aa84ff)",
	cachydgreen = "rgba(007d6fff)",
	cachylblue = "rgba(01ccffff)",
	cachymblue = "rgba(182545ff)",
	cachydblue = "rgba(111826ff)",
	cachywhite = "rgba(ffffffff)",
	cachygrey = "rgba(ddddddff)",
	cachygray = "rgba(798bb2ff)",
}

local walPath = os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf"
local file = io.open(walPath, "r")

if file ~= nil then
	for line in file:lines() do
		local key, value = line:match("^%s*%$([%w_]+)%s*=%s*(%S+)")
		if key ~= nil and value ~= nil then
			colors[key] = value
		end
	end

	file:close()
end

return colors
