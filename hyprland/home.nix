{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    hyprshot
    brightnessctl
    rofi-wayland
    xorg.xrdb # For kde-style xwayland scaling

    # These packages are required for kcmshell to work
    kdePackages.kirigami-addons
    kdePackages.kitemmodels
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # TODO: https://wiki.nixos.org/wiki/Hyprland config is nix
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  programs.waybar = {
    enable = true;
    settings = import ./waybar.nix;
    style = builtins.readFile ./waybar.css;
  };

  # TODO: make this not look like shit
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

  # TODO: Configure
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
      # icon = "hibernate";
      genericName = "Hibernate";
    };
    suspend = {
      name = "Suspend";
      exec = "systemctl suspend-then-hibernate";
      # icon = "suspend";
      genericName = "Put System to Sleep";
    };
    shutdown = {
      name = "Shut Down";
      exec = "shutdown -h now";
      # icon = "poweroff";
      genericName = "Power off the System";
    };
    reboot = {
      name = "Reboot";
      exec = "reboot";
      # icon = "restart";
      genericName = "Restart the System";
    };
    logout = {
      name = "Log out";
      # TODO: More graceful, universal command
      exec = "hyprctl dispatch exit";
      comment = "Exit Desktop";
    };

    networkconfig = {
      name = "Network";
      exec = "plasmawindowed org.kde.plasma.networkmanagement";
      icon = "settings";
      genericName = "Plasma Network Config";
    };
    bluetooth = {
      name = "Bluetooth";
      exec = "plasmawindowed org.kde.plasma.bluetooth";
      icon = "bluetooth";
      genericName = "Plasma Bluetooth Config";
    };
    volume = {
      name = "Audio";
      # exec = "plasmawindowed org.kde.plasma.volume";
      exec = "kcmshell6 kcm_pulseaudio"; # NOTE:
      icon = "preferences-desktop-sound";
      genericName = "Plasma Sound Config";
    };
  };
}
