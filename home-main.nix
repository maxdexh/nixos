{
  G,
  lib,
  config,
  ...
}: {
  imports = G.findAutoImports "home";

  lib.file.mkNixConfigSymlink = p:
    if G.host.nixosConfigLocation == ""
    then p
    else let
      # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
      # Could also be done without the builtin by traversing backwards using
      # `+ "/.."` and using `baseNameOf` to get each path segment.
      path = builtins.unsafeDiscardStringContext (toString p);
      base = lib.strings.removeSuffix "/" "${G.inputs.self}";
      relpath = assert lib.strings.hasPrefix base path; lib.strings.removePrefix base path;
    in
      config.lib.file.mkOutOfStoreSymlink (G.host.nixosConfigLocation + relpath);

  xdg.enable = true;

  home.stateVersion = "25.05";
}
