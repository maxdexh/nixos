{
  config,
  G,
  ...
}: {
  imports = let
    hardware = G.inputs.nixos-hardware.nixosModules;
  in [
    hardware.common-pc
    hardware.common-pc-ssd
    hardware.common-gpu-nvidia-nonprime
    hardware.common-cpu-amd
    hardware.common-cpu-amd-zenpower
    ./hardware-configuration.nix
  ];

  # NOTE: `hardware.nvidia.enabled` is set based on this
  services.xserver.videoDrivers = ["nvidia"];

  # TODO: Reconsider kernel params
  boot.kernelParams = ["nvidia_drm.fbdev=1" "nvidia-drm.modeset=1" "module_blacklist=i915"];

  # TODO: Reconsider
  hardware.nvidia = {
    forceFullCompositionPipeline = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  services.logind = {
    extraConfig = ''
      IdleAction=suspend-then-hibernate
      IdleActionSec=60m
    '';
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60m
    SuspendState=mem
  '';

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            z = "y";
            y = "z";
            capslock = "esc";
          };
          # Assumes AltGr key combining with ä on q, ö on p, ü on y.
          altgr = {
            a = "G-q";
            o = "G-p";
            u = "G-y";
          };
        };
      };
    };
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };
}
