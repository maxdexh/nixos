{
  config,
  pkgs,
  G,
  ...
}: {
  home.packages = with pkgs; [
    tree-sitter
    (writeShellScriptBin "nvim-unstable" "exec -a $0 ${G.pkgs-unstable.neovim}/bin/nvim $@")
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkNixConfigSymlink ./nvim;

  systemd.user.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
