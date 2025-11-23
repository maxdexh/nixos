{
  pkgs,
  lib,
  config,
  ctx,
  ...
}: lib.mkMerge [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [openvpn gnumake];

    programs.steam.enable = config.custom.host.fullDesktop;
  })

  (ctx.hm.set {
    # Misc applications
    home.packages = lib.mkIf config.custom.host.fullDesktop (with pkgs; [
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

      lunar-client
      prismlauncher
    ]);
  })
]
