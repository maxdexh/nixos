{inputs, ...}: {
  hosts.fw13 = {
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
        # NOTE: This does not work when put into ./hyprland.conf and I have no idea why
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
        };
      };
    };

    nixos.enable = true;
    nixos.module.imports = [
      ./os.nix
      inputs.nixos-hardware.nixosModules.framework-13-7040-amd
      ./hardware-configuration.nix
    ];

    nixConfigLocation = "/etc/nixos";

    tags = {
      personal = true;
      fullDesktop = true;
      nixos = true;
      laptop = true;
      qwertyPatch = true;
    };
  };
}
