{ ... }:

{
  # TODO: Consider configuring through nix
  xdg.configFile."kitty".source = ./kitty;
  # programs.kitty = {
  #   enable = true;
  #   enableGitIntegration = true;
  #   extraConfig = ./kitty/kitty.conf;
  # };
}
