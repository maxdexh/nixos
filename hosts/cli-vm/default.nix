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

    nixos.module = {pkgs, ...}: let
      shared_variant_opts = {
        virtualisation = {
          graphics = false;
          qemu = {
            consoles = ["hvc0"];
            options = [
              "-sandbox"
              "on,elevateprivileges=deny"
              "-no-user-config"

              # Disable the default serial console and QEMU monitor on stdio.
              "-serial"
              "none"
              "-monitor"
              "none"

              # Use a virtio console connected directly to the terminal.
              "-device"
              "virtio-serial"
              "-chardev"
              "stdio,id=console,signal=off"
              "-device"
              "virtconsole,chardev=console"
            ];
          };
          cores = 4;
          memorySize = 8192; # 8 GiB
        };
      };
    in {
      services.qemuGuest.enable = true;

      virtualisation.vmVariantWithBootLoader = lib.mkMerge [
        {
          boot.loader.timeout = 0;
          boot.growPartition = true;

          boot.kernelParams = [
            "console=hvc0"
          ];

          virtualisation = {
            # don't share /nix/store
            useBootLoader = true;
            mountHostNixStore = false; # (implied)

            fileSystems."/".autoResize = true;

            diskSize = 50 * 1024; # 50 GiB
          };
        }
        shared_variant_opts
      ];
      virtualisation.vmVariant = lib.mkMerge [
        {
          virtualisation = {
            diskSize = 20 * 1024; # 20 GiB
          };
        }
        shared_variant_opts
      ];

      environment.systemPackages = [pkgs.kitty.terminfo]; # To make TERM=xterm-kitty work
      environment.variables.TERM = "xterm-kitty"; # FIXME: Try to auto pass this from host

      security.sudo.enable = false;
      security.sudo-rs.enable = false;
      users.users.root.hashedPassword = "!";

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
