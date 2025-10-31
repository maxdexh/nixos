{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.custom.host.fullDesktop {
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
    krita
    libreoffice-qt6
    xournalpp
    vscode
    brave
    thunderbird
    gnome-system-monitor
    discord
    zathura
  ];
}
