{config, ...}: {
  services.logind.settings.Login = {
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "60m";
  };
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "120m";
    SuspendState = "mem";
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # Required for 8bitdo controllers to be detected by the software through wine/webusb.
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2dc8", MODE="0666", GROUP="users", TAG+="uaccess"
  '';
}
