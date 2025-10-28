{
  config,
  pkgs,
  G,
  ...
}: {
  home.packages = with pkgs; [
    tree-sitter
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkNixConfigSymlink ./nvim;

  systemd.user.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    NVIM_NIX_CONFIG_ROOT = config.custom.host.nixConfigLocation;
    NVIM_NIX_HOST_NAME = G.host.name;
    NVIM_NIX_IS_NIXOS = toString (G.host.isNixOS);
    NVIM_NIX_HM_STANDALONE = toString (G.host.isHmStandalone);
  };
}
