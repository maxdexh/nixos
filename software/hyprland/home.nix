{ pkgs, ... }:

{
  imports = [ ./waybar.nix ];
  home.packages = with pkgs; [
    waybar
    hyprshot
    hyprpicker
    brightnessctl
    rofi-wayland
    xorg.xrdb # For kde-style xwayland scaling
    killall
    playerctl

    # These packages are required for kcmshell to work
    kdePackages.kirigami-addons
    kdePackages.kitemmodels
    kdePackages.kdeclarative
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  # TODO: Try other daemons
  services.dunst = {
    enable = true;
    # https://discourse.nixos.org/t/tip-how-to-enable-dunst-for-only-select-des-with-nix/65630
    package = pkgs.writeShellScriptBin "dunst" ''
      if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
        echo "Dunst: Not starting because session is KDE Plasma."
        exit 0
      fi
      exec ${pkgs.dunst}/bin/dunst "$@"
    '';
    configFile = ./dunstrc;
  };

  # TODO: Configure more default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "text/html" = "firefox.desktop";

      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";

      # TODO: Add desktop entry that opens a new kitty tab with nvim for text
    };
  };

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
      exec = "systemctl --user exit";
      icon = "system-users";
      comment = "Exit Desktop";
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
