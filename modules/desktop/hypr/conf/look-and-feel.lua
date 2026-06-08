hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 1,
		col = {
			active_border = {
				colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
				angle = 45,
			},
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "dwindle",
	},
})

hl.config({
	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.1,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = false,
		},
	},
})

hl.config({
	animations = {
		enabled = false,
	},
})

hl.workspace_rule({
	workspace = "w[tv1]",
	gaps_out = 0,
	gaps_in = 0,
})

hl.workspace_rule({
	workspace = "f[1]",
	gaps_out = 0,
	gaps_in = 0,
})

hl.window_rule({
	match = { workspace = "w[tv1]" },
	rounding = 0,
	border_size = 0,
})

hl.window_rule({
	match = { workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		-- vfr = true
	},
})
