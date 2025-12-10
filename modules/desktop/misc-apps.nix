{
  parts.misc-desktop-apps = {
    tags = ["desktop"];

    nixos = {
      host,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [openvpn gnumake];

      programs.steam.enable = host.fullDesktop;
    };

    hm = {pkgs, ...}: {
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
    };
  };
}
