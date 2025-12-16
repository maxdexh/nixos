{
  parts.capslock-escape = {
    enableIf.tags.fullDesktop = true;
    nixos.services.keyd = {
      enable = true;
      keyboards.default = {
        settings.main.capslock = "esc";
      };
    };
  };

  parts.iso-remap = {
    enableIf.tags.qwertyPatch = true;
    nixos.services.keyd = {
      enable = true;
      keyboards.default = {
        settings = {
          main = {
            z = "y";
            y = "z";
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

  parts.keyd-palm-reject-fix = {
    enableIf.tags.laptop = true;
    nixos = {
      config,
      lib,
      ...
    }: {
      environment.etc."libinput/local-overrides.quirks" = lib.mkIf config.services.keyd.enable {
        text = ''
          [Serial Keyboards]
          MatchUdevType=keyboard
          MatchName=keyd virtual keyboard
          AttrKeyboardIntegration=internal
        '';
      };
    };
  };
}
