{
  parts.misc-desktop-apps = {
    enableIf.tags.fullDesktop = true;

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [openvpn gnumake];

      programs.steam.enable = true;

      services.flatpak.enable = true;
    };

    hm = {pkgs, ...}: {
      home.packages = with pkgs; [
        baobab
        gparted

        vlc
        losslesscut-bin
        obs-studio
        gimp

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
