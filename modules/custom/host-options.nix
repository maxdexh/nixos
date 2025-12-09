{
  lib,
  inputs,
  ctx,
  config,
  host,
  ...
}: let
  iso_layout = host.usIsoLayout.enable;
  iso_remap = iso_layout && host.usIsoLayout.remaps;

  path_prefix = "${inputs.self}/";
in {
  config = lib.mkMerge [
    {
      # TODO: Move this to host too somehow?
      custom.lib.mkNixConfigSymlink = path: assert builtins.isPath path;
        if host.nixConfigLocation == inputs.self.outPath # Fewer symlinks
        then path
        else let
          # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
          # Could also be done without the builtin by traversing backwards using
          # `+ "/.."` and using `baseNameOf` to get each path segment.
          abs = builtins.unsafeDiscardStringContext (toString path);
          rel = assert lib.hasPrefix path_prefix abs; lib.removePrefix path_prefix abs;
        in config.lib.file.mkOutOfStoreSymlink "${host.nixConfigLocation}/${rel}";
    }
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
      environment.etc."libinput/local-overrides.quirks" = lib.mkIf (iso_remap && host.laptop.enable) {
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
