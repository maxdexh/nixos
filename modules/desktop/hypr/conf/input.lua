-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
	input = {
		repeat_rate = 60,
		repeat_delay = 175,
		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	-- 1800 DPI, Configured via Piper
	name = "logitech-g502-hero-se",
	sensitivity = -0.0,
	accel_profile = "flat",
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures
hl.config({
	gestures = {
		-- TODO
	},
})
