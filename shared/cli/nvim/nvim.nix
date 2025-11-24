{
  config,
  pkgs,
  host,
  ctx,
  ...
}:
ctx.hm.set {
  home.packages = with pkgs; [
    tree-sitter
  ];

  xdg.configFile."nvim".source =
    config.lib.custom.mkNixConfigSymlink ./.;

  custom.sessionVars = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    NVIM_NIX_HOST_NAME = host.name;
    NVIM_NIX_IS_NIXOS = toString (host.nixOS);
  };
}
