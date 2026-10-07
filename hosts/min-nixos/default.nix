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
    nixos.module.imports = [
      {
        services.qemuGuest.enable = true;
        virtualisation.diskSize = 20 * 1024; # 20 GiB
        virtualisation.vmVariant = {
          virtualisation.cores = 1;
          virtualisation.memorySize = 4096; # 4 GiB
        };

        # allow poweroff
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (
              action.id == "org.freedesktop.login1.power-off"
            ) {
              return polkit.Result.YES;
            }
          });
        '';
      }
    ];

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
