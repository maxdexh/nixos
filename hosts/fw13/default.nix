{inputs, ...}: {
  hosts.fw13 = {
    users.max = {
      hm.module.home.homeDirectory = "/home/max";
    };

    hm.shared.module = {host, ...}: {
      wayland.windowManager.hyprland.settings.source = [
        "${host.mkNixConfigSymlink ./hyprland.conf}"
      ];
    };

    nixos.enable = true;
    nixos.module.imports = [
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

    tags = {
      desktop = true;
    };
  };
}
