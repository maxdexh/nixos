{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.fullDesktop {
  home.packages = with pkgs; [
    # These packages are required for the kcmshell desktop entries to work in hyprland
    kdePackages.kirigami-addons
    kdePackages.kitemmodels
    kdePackages.kdeclarative
    kdePackages.knewstuff # For kde system settings
  ];

  xdg.desktopEntries = {
    hibernate = {
      name = "Hibernate";
      exec = "systemctl hibernate";
      icon = "system-hibernate";
      genericName = "Hibernate";
    };
    suspend = {
      name = "Suspend";
      exec = "systemctl suspend-then-hibernate";
      icon = "system-suspend";
      genericName = "Put System to Sleep";
    };
    shutdown = {
      name = "Shut Down";
      exec = "shutdown -h now";
      icon = "system-shutdown";
      genericName = "Power off the System";
    };
    reboot = {
      name = "Reboot";
      exec = "reboot";
      icon = "system-reboot";
      genericName = "Restart the System";
    };
    logout = {
      name = "Log out";
      exec = let
        logout = pkgs.writeShellApplication {
          name = "logout";
          text = ''
            if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
              exec qdbus org.kde.Shutdown /Shutdown logout
            else
              exec uwsm stop
            fi
          '';
        };
      in
        lib.getExe logout;
      icon = "system-log-out";
      comment = "Exit Desktop";
      settings = {Keywords = "logout";};
    };
    networkconfig = {
      name = "Network";
      exec = "plasmawindowed org.kde.plasma.networkmanagement";
      icon = "preferences-system-network";
      genericName = "Network Config";
    };
    bluetooth = {
      name = "Bluetooth";
      exec = "plasmawindowed org.kde.plasma.bluetooth";
      icon = "preferences-system-bluetooth";
      genericName = "Bluetooth Config";
    };
    volume = {
      name = "Audio";
      exec = "kcmshell6 kcm_pulseaudio";
      icon = "preferences-desktop-sound";
      genericName = "Sound Config";
    };
    energy = {
      name = "Energy";
      exec = "kcmshell6 kcm_energyinfo";
      icon = "preferences-system-power-management";
      genericName = "Energy Monitor";
    };
  };
}
