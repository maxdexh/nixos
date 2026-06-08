require("hosts.generic.altgr-intl")

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- discord")
end)
