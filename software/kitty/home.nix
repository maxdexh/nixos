{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    extraConfig = builtins.readFile ./kitty/kitty.conf;
  };

  home.packages = with pkgs; [ tdf ];
}
