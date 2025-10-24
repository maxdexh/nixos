{...}: {
  boot.kernelParams = [
    # Adaptive brightness level (local dimming), power saving
    "amdgpu.abmlevel=2"
  ];

  # TODO: Reconsider most of these
  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = false; # Not needed with ppd
  services.upower.enable = true;
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
