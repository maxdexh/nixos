{
  pkgs,
  lib,
  host,
  ...
}:
lib.mkIf host.fullDesktop {
  # Misc applications
  home.packages = with pkgs; [
    # disk utils
    baobab
    gparted

    # games
    prismlauncher
    # lunar-client

    # gui apps
    obs-studio
    gimp
    vscode
    brave
    thunderbird
    gnome-system-monitor
    discord
    zathura
  ];
}
