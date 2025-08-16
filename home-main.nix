{G, ...}: {
  imports = G.findAutoImports "/home.nix";

  # broken under flakes
  programs.command-not-found.enable = false;

  xdg.enable = true;

  home.stateVersion = "25.05";
}
