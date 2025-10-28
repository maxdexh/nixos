{
  lib,
  inputs,
  ctx,
  config,
  configPathToRel,
  ...
}: let
  cfg = config.custom.host;
  iso_layout = cfg.usIsoLayout.enable;
  iso_remap = iso_layout && cfg.usIsoLayout.remaps;
in {
  options.custom.host = {
    laptop.enable = lib.mkEnableOption "laptop";

    usIsoLayout = {
      enable = lib.mkEnableOption "US ISO Keyboard Layout";
      remaps = lib.mkEnableOption "US ISO Keyboard Remaps";
    };

    fullDesktop = lib.mkEnableOption "Whether a full desktop environment is available";
    termux = lib.mkEnableOption "Whether the host is termux/nix-on-droid";

    nixConfigLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkMerge [
    {
      custom.host.termux = lib.mkDefault false;
      custom.host.fullDesktop = lib.mkDefault (!config.custom.host.termux);

      lib.custom.mkNixConfigSymlink = p:
        if cfg.nixConfigLocation == null
        then p
        else config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigLocation}/${configPathToRel p}";
    }
    (ctx.os.set {
      nix.nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
        "nixos-config=${config.custom.host.nixConfigLocation}/configuration.nix"
      ];
    })
    (ctx.hm.set {
      wayland.windowManager.hyprland.settings.input = lib.mkIf iso_layout {
        kb_layout = "us";
        kb_variant = "altgr-intl";
      };
    })
    (ctx.os.set {
      services.xserver.xkb = lib.mkIf iso_layout {
        layout = "us";
        variant = "altgr-intl";
      };
    })
    (ctx.os.set {
      services.keyd = lib.mkIf iso_remap {
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
    })
    (ctx.os.set {
      environment.etc."libinput/local-overrides.quirks" = lib.mkIf (iso_remap && cfg.laptop.enable) {
        text = ''
          [Serial Keyboards]
          MatchUdevType=keyboard
          MatchName=keyd virtual keyboard
          AttrKeyboardIntegration=internal
        '';
      };
    })
  ];
}
