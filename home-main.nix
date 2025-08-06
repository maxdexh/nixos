{G, ...}: {
  imports = G.findAutoImports "/home.nix";

  xdg.enable = true;

  home.stateVersion = "25.05";
}
