{inputs, ...}: {
  hosts.fw13 = {
    sharedHmModules = [
      ({config, ...}: {
        wayland.windowManager.hyprland.settings.source = [
          "${config.custom.lib.mkNixConfigSymlink ./hyprland.conf}"
        ];
      })
    ];

    nixos.enable = true;
    nixos.modules = [
      ./os.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ./hardware-configuration.nix
    ];

    nixConfigLocation = "/etc/nixos";
    usIsoLayout = {
      enable = true;
      remaps = true;
    };

    laptop.enable = true;
  };
}
