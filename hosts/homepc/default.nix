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
      wayland.windowManager.hyprland.settings = {
        source = [
          "${host.mkNixConfigSymlink ./hyprland.conf}"
        ];
      };
    };

    nixos.enable = true;
    nixos.module.imports = let
      hardware = inputs.nixos-hardware.nixosModules;
    in [
      ./os.nix
      hardware.common-pc
      hardware.common-pc-ssd
      hardware.common-gpu-amd
      hardware.common-cpu-amd
      hardware.common-cpu-amd-pstate
      hardware.common-cpu-amd-zenpower
      ./hardware-configuration.nix
    ];
    nixos.module.services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    # nixConfigLocation = "/etc/nixos";

    tags = {
      personal = true;
      fullDesktop = true;
      nixos = true;
      laptop = false;
      qwertyPatch = true;
    };
  };
}
