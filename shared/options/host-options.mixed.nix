{
  lib,
  G,
  config,
  ...
}: let
  cfg = config.custom.host;
  isoLayout = cfg.usIsoLayout.enable;
  isoRemap = isoLayout && cfg.usIsoLayout.remaps;
  isoRemapFix = isoRemap && cfg.laptop.enable;
in {
  options.custom.host = {
    laptop.enable = lib.mkEnableOption "laptop";

    usIsoLayout = {
      enable = lib.mkEnableOption "US ISO Keyboard Layout";
      remaps = lib.mkEnableOption "Remap Umlaut";
    };

    nixConfigLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = G.pickCtx {
    home = {
      lib.file.mkNixConfigSymlink = p:
        if cfg.nixConfigLocation == ""
        then p
        else let
          # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
          # Could also be done without the builtin by traversing backwards using
          # `+ "/.."` and using `baseNameOf` to get each path segment.
          path = builtins.unsafeDiscardStringContext (toString p);
          base = lib.strings.removeSuffix "/" "${G.inputs.self}";
          relpath = assert lib.strings.hasPrefix base path; lib.strings.removePrefix base path;
        in
          config.lib.file.mkOutOfStoreSymlink (cfg.nixConfigLocation + relpath);

      wayland.windowManager.hyprland.settings = lib.mkIf isoLayout {
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
        };
      };
    };
    system = {
      services.xserver.xkb = lib.mkIf isoLayout {
        layout = "us";
        variant = "altgr-intl";
      };
      services.keyd = lib.mkIf isoRemap {
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
      environment.etc."libinput/local-overrides.quirks" = lib.mkIf isoRemapFix {
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
