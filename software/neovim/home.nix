{
  G,
  config,
  ...
}: {
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink G.localConfigRoot
    + "/software/neovim/nvim";

  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
