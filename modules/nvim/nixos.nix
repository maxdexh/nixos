{
  custom,
  pkgs,
  host,
  ctx,
  ...
}:
ctx.hm.set {
  home.packages = with pkgs; [
    tree-sitter
    nixd
  ];

  xdg.configFile."nvim".source = custom.lib.mkNixConfigSymlink ./.;

  custom.sessionVars = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    NVIM_NIX_HOST_NAME = host.name;
    NVIM_NIX_IS_NIXOS = toString (host.nixOS);
  };
}
