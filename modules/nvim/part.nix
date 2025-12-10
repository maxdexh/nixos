{
  pkgs,
  host,
  ...
}: {
  parts.nvim = {
    tags = ["default"];
    hm = {
      home.packages = with pkgs; [
        tree-sitter
        nixd
      ];

      xdg.configFile."nvim".source = host.mkNixConfigSymlink ./.;

      custom.sessionVars = {
        VISUAL = "nvim";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        NVIM_NIX_HOST_NAME = host.name;
        NVIM_NIX_IS_NIXOS = toString host.nixos.enable;
      };
    };
  };
}
