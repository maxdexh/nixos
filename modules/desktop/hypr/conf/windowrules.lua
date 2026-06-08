hl.window_rule({
	match = {},
	suppress_event = "maximize",
})

hl.window_rule({
	match = { class = "steam" },
	workspace = "name:steam silent",
})

hl.window_rule({
	match = { class = "xwaylandvideobridge" },
	opacity = "0 override",
})

hl.window_rule({
	match = { class = "discord" },
	workspace = "name:dc silent",
})
