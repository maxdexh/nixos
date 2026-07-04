{inputs, ...}: {
  hosts.homepc = {
    users.max = {
      nixos.user = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
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
