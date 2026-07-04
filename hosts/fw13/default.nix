{inputs, ...}: {
  hosts.fw13 = {
    users.max = {
      nixos.user = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
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
