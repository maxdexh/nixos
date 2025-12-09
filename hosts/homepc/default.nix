{inputs, ...}: {
  hosts.homepc = {
    sharedHmModules = [
      ({config, ...}: {
        wayland.windowManager.hyprland.settings.source = [
          "${config.custom.lib.mkNixConfigSymlink ./hyprland.conf}"
        ];
      })
    ];

    nixos.enable = true;
    nixos.modules = let
      hardware = inputs.nixos-hardware.nixosModules;
    in [
      ./os.nix
      hardware.common-pc
      hardware.common-pc-ssd
      hardware.common-gpu-nvidia-nonprime
      hardware.common-cpu-amd
      hardware.common-cpu-amd-zenpower
      ./hardware-configuration.nix
    ];

    nixConfigLocation = "/etc/nixos";
    usIsoLayout = {
      enable = true;
      remaps = true;
    };
  };
}
