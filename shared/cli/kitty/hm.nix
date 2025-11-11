{
  pkgs,
  lib,
  config,
  ...
}: lib.mkIf config.custom.host.fullDesktop {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    extraConfig = "include ${config.lib.custom.mkNixConfigSymlink ./kitty.conf}";
  };

  home.packages = with pkgs; [tdf];
}
