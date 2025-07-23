{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ openvpn ];

  programs.steam.enable = true;
}
