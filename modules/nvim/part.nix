{
  parts.nvim = {
    enableIf.tags.personal = true;

    hm = {
      host,
      pkgs,
      config,
      ...
    }: {
      home.packages = with pkgs; [
        tree-sitter
        nixd
        bob-nvim # nvim bugs are too frequent
      ];

      xdg.configFile."nvim".source = host.mkNixConfigSymlink ./.;

      custom.sessionVars = {
        VISUAL = "nvim";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        NVIM_NIX_HOST_NAME = host.name;
        NVIM_NIX_IS_NIXOS = toString host.nixos.enable;
      };

      home.sessionPath = ["${config.xdg.dataHome}/bob/nvim-bin"];
    };
  };
}
