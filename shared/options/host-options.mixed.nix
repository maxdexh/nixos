{
  lib,
  inputs,
  ctx,
  config,
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

    nixConfigLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkMerge [
    {
      lib.file.mkNixConfigSymlink = p:
        if cfg.nixConfigLocation == null
        then p
        else config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigLocation}/${config.lib.file.configPathToRel p}";
    }
    (ctx.os.mod {
      nix.nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
        "nixos-config=${config.custom.host.nixConfigLocation}/configuration.nix"
      ];
    })
    (ctx.hm.mod {
      wayland.windowManager.hyprland.settings.input = lib.mkIf iso_layout {
        kb_layout = "us";
        kb_variant = "altgr-intl";
      };
    })
    (ctx.os.mod {
      services.xserver.xkb = lib.mkIf iso_layout {
        layout = "us";
        variant = "altgr-intl";
      };
    })
    (ctx.os.mod {
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
    (ctx.os.mod {
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
