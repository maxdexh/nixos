{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ openvpn gnumake ];

  programs.steam.enable = true;
}
