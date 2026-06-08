return {
	set_xwayland_scale = function(ratio)
		-- Mimics KDE's XWayland fractional scaling
		local dpi = 96.0 * ratio
		hl.on("hyprland.start", function()
			hl.exec_cmd("bash -c 'echo Xft.dpi: " .. dpi .. " | xrdb -merge'")
		end)

		hl.config({
			xwayland = {
				force_zero_scaling = true,
			},
		})
	end,
}
