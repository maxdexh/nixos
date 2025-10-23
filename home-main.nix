{G, ...}: {
  imports = G.findAutoImports "home";

  xdg.enable = true;

  home.stateVersion = "25.05";
}
