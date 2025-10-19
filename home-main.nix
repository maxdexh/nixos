{
  G,
  lib,
  config,
  ...
}: {
  imports = (G.findAutoImports "/home.nix") ++ (G.findAutoImports ".home.nix");

  lib.file.symlinkNixConfig = p:
    if G.host.localConfigRoot == ""
    then p
    else let
      # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
      # Can also be done without the builtin by traversing backwards using
      # `+ "/.."` and using `baseNameOf` to get each path segment.
      path = builtins.unsafeDiscardStringContext (toString p);
      base = lib.strings.removeSuffix "/" "${G.inputs.self}";
      relpath = assert lib.strings.hasPrefix base path; lib.strings.removePrefix base path;
    in
      config.lib.file.mkOutOfStoreSymlink (G.host.localConfigRoot + relpath);

  xdg.enable = true;

  home.stateVersion = "25.05";
}
