{
  pkgs,
  lib,
  config,
  ...
}: lib.mkIf config.custom.host.fullDesktop {
  # Misc applications
  home.packages = with pkgs; [
    vlc
    losslesscut-bin

    # disk utils
    baobab
    gparted

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
