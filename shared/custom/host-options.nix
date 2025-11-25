{
  lib,
  inputs,
  ctx,
  config,
  custom,
  ...
}: let
  iso_layout = cfg.usIsoLayout.enable;
  iso_remap = iso_layout && cfg.usIsoLayout.remaps;

  path_prefix = "${inputs.self}/";

  cfg = custom.host;
in {
  # FIXME: Move the host special arg into here so
  options.custom.host = {
    laptop.enable = lib.mkEnableOption "laptop";
    cliOnly.enable = lib.mkEnableOption "cli config only";

    usIsoLayout = {
      enable = lib.mkEnableOption "US ISO Keyboard Layout";
      remaps = lib.mkEnableOption "US ISO Keyboard Remaps";
    };

    fullDesktop = lib.mkEnableOption "Whether a full desktop environment is available";

    nixConfigLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkMerge [
    (lib.setAttrByPath ["custom"] {
      host.fullDesktop = lib.mkDefault (!cfg.cliOnly.enable);

      lib.mkNixConfigSymlink = path: assert builtins.isPath path;
        if cfg.nixConfigLocation == null
        then path
        else let
          # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
          # Could also be done without the builtin by traversing backwards using
          # `+ "/.."` and using `baseNameOf` to get each path segment.
          abs = builtins.unsafeDiscardStringContext (toString path);
          rel = assert lib.hasPrefix path_prefix abs; lib.removePrefix path_prefix abs;
        in config.lib.file.mkOutOfStoreSymlink "${cfg.nixConfigLocation}/${rel}";
    })
    (ctx.os.set {
      nix.nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
        "nixos-config=${custom.host.nixConfigLocation}"
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
