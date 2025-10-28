{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  # TODO: udev rule to prevent the keyboard & touchpad from waking the device from sleep
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "ignore";

    powerKey = "suspend-then-hibernate";
    # This is seperate from the 10s force power cut handled by BIOS
    powerKeyLongPress = "poweroff";

    extraConfig = ''
      IdleAction=suspend-then-hibernate
      IdleActionSec=5m
    '';
  };
  # Hibernate after 15min of sleep
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
    SuspendState=mem
  '';
}
