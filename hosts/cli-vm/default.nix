{lib, ...}: {
  hosts.cli-vm = {
    users.max = {
      nixos.user = {
        isNormalUser = true;
        extraGroups = lib.mkForce []; # no wheel
        initialPassword = "";
      };
    };

    nixos.enable = true;

    # Build using `nix run nixpkgs#nixos-rebuild -- build-vm-with-bootloader --flake path-to-here#cli-vm`
    # Run using `QEMU_OPTS="-nographic -serial mon:stdio" ./result/bin/run-*-vm`
    nixos.module = {...}: {
      services.qemuGuest.enable = true;

      virtualisation.vmVariantWithBootLoader = {
        boot.loader.timeout = 0;
        boot.kernelParams = [
          "console=ttyS0"
        ];

        virtualisation = {
          # don't share /nix/store
          useBootLoader = true;
          mountHostNixStore = false; # (implied)

          cores = 4;
          memorySize = 8192; # 8 GiB
          diskSize = 50 * 1024; # 50 GiB

          # override for fetching with QEMU_NET_OPTS=restrict=off
          restrictNetwork = true;

          qemu.options = [
            "-sandbox"
            "on,elevateprivileges=deny"
            "-no-user-config"
          ];
        };
      };

      security.sudo.enable = false;
      security.sudo-rs.enable = false;
      users.users.root.hashedPassword = "!";

      # VM for testing, build using `build-vm` instead of `build-vim-with-bootloader`.
      # Needs `QEMU_KERNEL_PARAMS="console=ttyS0"` when running as described above
      # Uses the system nix store instead of having its own, and does less sandboxing
      virtualisation.vmVariant = {
        virtualisation = {
          cores = 4;
          memorySize = 8192; # 8 GiB
          diskSize = 20 * 1024; # 20 GiB
        };
      };

      # allow poweroff
      security.polkit.enable = true;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            action.id == "org.freedesktop.login1.power-off"
          ) {
            return polkit.Result.YES;
          }
        });
      '';
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
