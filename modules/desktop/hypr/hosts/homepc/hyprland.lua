require("hosts.generic.altgr-intl")

hl.monitor({
	output = "desc:Samsung Electric Company Odyssey G50F",
	mode = "2560x1440@179.95Hz",
	position = "auto",
	scale = 1,
})
hl.monitor({
	output = "desc:Iiyama North America PLE2483H",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- discord")
end)
