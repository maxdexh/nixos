{
  inputs,
  ctx,
  custom,
  ...
}: builtins.trace ctx.kind {
  imports =
    [
      ./os.nix
      ./host-config.nix
    ]
    ++ ctx.os.list (let
      hardware = inputs.nixos-hardware.nixosModules;
    in [
      hardware.common-pc
      hardware.common-pc-ssd
      hardware.common-gpu-nvidia-nonprime
      hardware.common-cpu-amd
      hardware.common-cpu-amd-zenpower
      ./hardware-configuration.nix
    ]);

  config = ctx.hm.set {
    wayland.windowManager.hyprland.settings.source = [
      "${custom.lib.mkNixConfigSymlink ./hyprland.conf}"
    ];
  };
}
