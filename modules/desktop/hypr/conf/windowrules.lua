hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	match = { class = "steam" },
	workspace = "name:ste silent",
})

hl.window_rule({
	match = { class = "xwaylandvideobridge" },
	opacity = "0 override",
})

hl.window_rule({
	match = { class = "discord" },
	workspace = "name:dc silent",
})
