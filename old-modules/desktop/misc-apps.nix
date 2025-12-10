{
  pkgs,
  lib,
  host,
  ctx,
  ...
}: lib.mkMerge [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [openvpn gnumake];

    programs.steam.enable = host.fullDesktop;
  })

  (ctx.hm.set {
    home.packages = with pkgs; [
      baobab
      gparted

      vlc
      losslesscut-bin
      obs-studio
      gimp
      krita

      libreoffice-qt6
      xournalpp

      vscode
      brave
      thunderbird # TODO: programs.thunderbird?
      gnome-system-monitor
      discord # TODO: programs.discord
      zathura

      prismlauncher
    ];
  })
]
