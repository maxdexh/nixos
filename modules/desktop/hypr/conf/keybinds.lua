-- TODO: Keychords (https://www.youtube.com/watch?v=jhIr9VN2znI)
-- TODO: Window groups

-- https://wiki.hyprland.org/Configuring/Binds/

---@param key string
---@return string
local function main_mod(key)
	return "SUPER + " .. key
end

---@param key string
---@return string
local function shift_mod(key)
	return main_mod("SHIFT + " .. key)
end

hl.bind(main_mod("Q"), hl.dsp.exec_cmd("uwsm-app -- kitty"))
hl.bind(main_mod("B"), hl.dsp.exec_cmd("killall -SIGUSR1 .waybar-wrapped"))
hl.bind(main_mod("R"), hl.dsp.exec_cmd('rofi -show drun -theme material -run-command "uwsm-app -- {cmd}"'))

hl.bind(main_mod("C"), hl.dsp.window.close())
hl.bind(shift_mod("C"), hl.dsp.window.kill())

hl.bind(main_mod("V"), hl.dsp.window.float())

hl.bind(main_mod("F"), hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(shift_mod("F"), hl.dsp.window.fullscreen({ mode = "maximized" }))

hl.bind(main_mod("h"), hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod("l"), hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod("k"), hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod("j"), hl.dsp.focus({ direction = "down" }))

---@type table<string, integer|string>
local wss = {
	d = "name:dc",
	p = "name:steam",
}
for i = 1, 10 do
	wss[tostring(i % 10)] = i
end
for k, ws in pairs(wss) do
	hl.bind(main_mod(k), hl.dsp.focus({ workspace = ws }))
	hl.bind(shift_mod(k), hl.dsp.window.move({ workspace = ws }))
end

hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot --freeze -m region"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot --freeze -m window"))
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("hyprshot --freeze -m output"))

hl.bind(main_mod("mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(shift_mod("mouse:272"), hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
