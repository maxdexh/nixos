{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    powertop
    nvme-cli
    smartmontools
  ];

  # TODO: udev rule to prevent the keyboard & touchpad from waking the device from sleep
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";

    HandlePowerKey = "suspend-then-hibernate";
    # This is seperate from the 10s force power cut handled by BIOS
    HandlePowerKeyLongPress = "poweroff";

    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "5m";
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=60m
    SuspendState=mem
  '';

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
