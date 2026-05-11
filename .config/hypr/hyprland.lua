local configDir = os.getenv("HOME") .. "/.config/hypr"
package.path = configDir .. "/?.lua;" .. configDir .. "/?/init.lua;" .. package.path

for _, module in ipairs({
	"config.autostart",
	"config.colors",
	"config.defaults",
	"config.environment",
	"config.input",
	"config.keybinds",
	"config.look",
	"config.misc",
	"config.monitors",
	"config.permission",
	"config.windowrules",
}) do
	package.loaded[module] = nil
end

require("config.keybinds")
require("config.monitors")
require("config.autostart")
require("config.environment")
require("config.permission")
require("config.input")
require("config.windowrules")
require("config.misc")
require("config.look")
