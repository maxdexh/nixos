{config, ...}: {
  services.logind.settings.Login = {
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "60m";
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=120m
    SuspendState=mem
  '';

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
}
