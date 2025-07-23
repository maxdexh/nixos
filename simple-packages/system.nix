{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wl-clipboard # wayland clipboard cli, used by neovim
    # xclip

    trash-cli # safer rm

    gcc
    python3
    uv

    git # git

    zip
    unzip # all my homies hate tar.gz

    openvpn
  ];

  # Steam.
  programs.steam.enable = true;
}
