{G, ...}: {
  imports = [
    G.inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  services.logind = {
    extraConfig = ''
      IdleAction=suspend-then-hibernate
      IdleActionSec=5m
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

  # environment.etc."libinput/local-overrides.quirks".text = ''
  #   [Serial Keyboards]
  #   MatchUdevType=keyboard
  #   MatchName=keyd virtual keyboard
  #   AttrKeyboardIntegration=internal
  # '';
}
