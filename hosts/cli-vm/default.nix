{...}: {
  # Build using `nix run nixpkgs#nixos-rebuild -- build-vm --flake path-to-here#nixos-cli-vm`
  # Run using `QEMU_OPTS="-nographic -serial mon:stdio" QEMU_KERNEL_PARAMS="console=ttyS0" ./result/bin/run-*-vm`
  hosts.cli-vm = {
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
        virtualisation.diskSize = 50 * 1024; # 50 GiB
        virtualisation.vmVariant.virtualisation = {
          cores = 4;
          memorySize = 8192; # 8 GiB

          restrictNetwork = true; # override using QEMU_NET_OPTS=restrict=off
          useNixStoreImage = true; # don't share /nix/store
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
