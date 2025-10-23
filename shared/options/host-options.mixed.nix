{
  lib,
  G,
  config,
  ...
}:
{
  options.custom.host = {
    laptop.enable = lib.mkEnableOption "laptop";

    nixConfigLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };
}
// (
  let
    cfg = config.custom.host;
  in {
    config.lib.file.mkNixConfigSymlink = p:
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
  }
)
