{pkgs, ...}: {
  # TODO: Use a git repo
  xdg.configFile."PFERD".source = ./PFERD;

  home.packages = with pkgs; [pferd];
}
