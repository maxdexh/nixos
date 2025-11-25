{
  inputs,
  ctx,
  custom,
  ...
}: {
  imports =
    [
      ./os.nix
      ./host-config.nix
    ]
    ++ ctx.os.list [
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ./hardware-configuration.nix
    ];

  config = ctx.hm.set {
    wayland.windowManager.hyprland.settings.source = [
      "${custom.lib.mkNixConfigSymlink ./hyprland.conf}"
    ];
  };
}
