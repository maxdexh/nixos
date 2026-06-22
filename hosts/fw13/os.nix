{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    powertop
    nvme-cli
    smartmontools
    (pkgs.writeShellScriptBin "fix-touchpad" ''
      sudo modprobe -r i2c_hid_acpi
      sudo modprobe i2c_hid_acpi
    '')
  ];

  hardware.fw-fanctrl = {
    enable = true;
  };

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
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "60m";
    SuspendState = "mem";
  };

  boot.kernelParams = [
    # Adaptive brightness level (local dimming), power saving
    "amdgpu.abmlevel=2"
  ];

  # https://wiki.archlinux.org/title/Iwd#EAP-PEAP for setting up PEAP networks
  # https://www.scc.kit.edu/dienste/7181.php
  networking.wireless.iwd.settings = {
    IPv6 = {
      Enabled = true;
    };
    Settings = {
      AutoConnect = true;
    };
  };
  networking.networkmanager.wifi.backend = "iwd";
  environment.etc."ssl/certs/T-TeleSec_GlobalRoot_Class_2.pem".source = ./${"T-TeleSec_GlobalRoot_Class_2.pem"};

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
