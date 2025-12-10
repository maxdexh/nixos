{lib, ...}: {
  parts.iso-layout = {
    tags = ["default"];
    hm = {
      lib,
      host,
      ...
    }: {
      wayland.windowManager.hyprland.settings.input = lib.mkIf host.usIsoLayout.enable {
        kb_layout = "us";
        kb_variant = "altgr-intl";
      };
    };
    nixos = {
      lib,
      host,
      ...
    }: {
      services.xserver.xkb = lib.mkIf host.usIsoLayout.enable {
        layout = "us";
        variant = "altgr-intl";
      };
    };
  };

  parts.iso-remap = {
    tags = ["default"];
    nixos = {
      lib,
      host,
      ...
    }: {
      services.keyd = lib.mkIf (host.usIsoLayout.enable && host.usIsoLayout.remaps) {
        enable = true;
        keyboards.default = {
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
  };

  parts.keyd-palm-reject-fix = {
    tags = ["default"];
    nixos = {
      config,
      host,
      ...
    }: {
      environment.etc."libinput/local-overrides.quirks" = lib.mkIf (config.services.keyd.enable && host.laptop.enable) {
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
