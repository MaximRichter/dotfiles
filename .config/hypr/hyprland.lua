local configDir = os.getenv("HOME") .. "/.config/hypr"
package.path = configDir .. "/?.lua;" .. configDir .. "/?/init.lua;" .. package.path

require("config.keybinds")
require("config.monitors")
require("config.autostart")
require("config.environment")
require("config.permission")
require("config.input")
require("config.windowrules")
require("config.misc")
require("config.look")
