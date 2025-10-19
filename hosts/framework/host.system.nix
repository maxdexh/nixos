{G, ...}: {
  imports = [
    G.inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  # TODO: udev rule to prevent the keyboard & touchpad from waking the device from sleep
  # TODO: Try making the lid switch wake the device
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

  boot.kernelParams = [
    # Enables AMD's preferred CPU scaling driver
    "amd_pstate=active"

    # Adaptive brightness level (local dimming), power saving
    "amdgpu.abmlevel=2"
  ];

  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = false; # Not needed with ppd
  services.upower.enable = true; # TODO: Remove
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

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

  # Fix palm rejection and disable-while-typing by telling libinput to treat the keyd virtual kb as a builtin keyboard
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
