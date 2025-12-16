{inputs, ...}: {
  hosts.homepc = {
    stateVersion = "25.05";

    users.max = {
      nixos.user = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
      };
    };

    hm.shared.module = {host, ...}: {
      wayland.windowManager.hyprland.settings.source = [
        "${host.mkNixConfigSymlink ./hyprland.conf}"
      ];
    };

    nixos.enable = true;
    nixos.module.imports = let
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

    # nixConfigLocation = "/etc/nixos";

    usIsoLayout = {
      enable = true;
      remaps = true;
    };

    tags = {
      personal = true;
      desktop = true;
    };
  };
}
