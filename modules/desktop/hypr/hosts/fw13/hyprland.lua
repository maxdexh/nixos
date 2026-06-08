require("hosts.generic.altgr-intl")

local main_scale = 4 / 3

require("hosts.util.scaling").set_xwayland_scale(main_scale)

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto-down",
	scale = main_scale,
})

hl.monitor({
	output = "DP-2",
	mode = "preferred",
	position = "auto-up",
	scale = 1,
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
