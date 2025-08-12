{pkgs, ...}: {
  xdg.configFile."PFERD".source = ./PFERD;

  home.packages = with pkgs; [pferd];
}
