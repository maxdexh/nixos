{
  # TODO: Build nvim config as part of system, or bootstrap an init.lua
  # to clone it.
  parts.nvim = {
    enableIf.tags.basic = true;

    hm = {
      host,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [
        tree-sitter
        nixd
      ];

      custom.sessionVars = {
        VISUAL = "nvim";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";

        # For nixd (see nvim config)
        NVIM_NIX_HOST_NAME = host.name;
        NVIM_NIX_IS_NIXOS = toString host.nixos.enable;
      };

      # home.sessionPath = ["${config.xdg.dataHome}/bob/nvim-bin"];
    };
  };
}
