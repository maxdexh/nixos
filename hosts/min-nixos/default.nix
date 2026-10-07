{...}: {
  hosts.min-nixos = {
    users.max = {
      nixos.user = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
        initialPassword = "";
      };
    };

    nixos.enable = true;
    nixos.module = {
      services.qemuGuest.enable = true;
      virtualisation.diskSize = 20 * 1024; # 20 GiB
      virtualisation.memorySize = 4096; # 4 GiB
      virtualisation.cores = 4;
    };

    tags = {
      basic = true;
      cli = true;
      nixos = true;

      fullDesktop = false;
      qwertyPatch = false;
      laptop = false;
      personal = false;
    };
  };
}
