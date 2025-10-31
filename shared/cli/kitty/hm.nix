{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.custom.host.fullDesktop {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    extraConfig = builtins.readFile ./kitty.conf;
  };

  home.packages = with pkgs; [tdf];
}
