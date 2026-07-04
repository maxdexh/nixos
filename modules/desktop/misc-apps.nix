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
        vlc
        losslesscut-bin

        xournalpp

        brave
        gnome-system-monitor
        discord
      ];

      programs.thunderbird = {
        enable = true;
        languagePacks = ["en-US" "de"];
      };
      programs.obs-studio.enable = true;
    };
  };
}
