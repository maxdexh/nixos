{config, ...}: {
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

  services.logind.settings.Login = {
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "60m";
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60m
    SuspendState=mem
  '';

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
}
