{
  config,
  pkgs,
  host,
  ...
}: {
  home.packages = with pkgs; [
    tree-sitter
  ];

  xdg.configFile."nvim".source =
    config.lib.custom.mkNixConfigSymlink ./nvim;

  custom.sessionVars = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    NVIM_NIX_CONFIG_ROOT = config.custom.host.nixConfigLocation;
    NVIM_NIX_HOST_NAME = host.name;
    NVIM_NIX_IS_NIXOS = toString (host.nixOS);
  };
}
