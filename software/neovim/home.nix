{config, pkgs, ...}: {
  home.packages = with pkgs; [tree-sitter];
  xdg.configFile."nvim".source =
    config.lib.file.linkLocalConfigFile ./nvim;

  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
