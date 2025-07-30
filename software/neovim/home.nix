{ config-meta, config, ... }:

{
  # TODO: Use a git repo
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    (config-meta.localConfigRoot + "/no-store/nvim");

  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
