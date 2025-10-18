{config, pkgs, ...}: {
  home.packages = with pkgs; [tree-sitter];
  xdg.configFile."nvim".source =
    config.lib.file.symlinkNixConfig ./nvim;

  systemd.user.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
