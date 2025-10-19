{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [qt6ct];
  systemd.user.sessionVariables = {
    # gtk.theme is dysfunctional, but this works nicely, except that it still has window decorations.
    GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

    # Configure via qt6ct (qt6 config tool):
    # - Appearance
    #   - Style: Breeze
    #   - Color Scheme: Style's Colors (set to 'darker' first because palettes are not set and remain white otherwise)
    #   - Standard Dialogs: KDE
    # - Fonts
    #   - General, Fixed Width: Noto Sans 10
    # - Icon Theme
    #   - Breeze Dark
    # - Interface
    #   - Dialog Buttons Layout, Keyboard Scheme: KDE
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Make electron apps use wayland directly rather than running through xwayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # No idea what this was, i think it had to do with electron using wayland too?
    NIXOS_OZONE_WL = "1";

    SUDO_ASKPASS = let
      askpass = pkgs.writeShellApplication {
        name = "askpass";
        runtimeInputs = [pkgs.rofi-wayland];
        text = ''
          rofi -theme material -dmenu -password -p "Password" -l 0 -theme-str 'mainbox { children: [inputbar]; }'
        '';
      };
    in
      lib.getExe askpass;

    TERMINAL = "kitty";

    GTK2_RC_FILES = config.gtk.gtk2.configLocation;
    XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
  };

  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtkrc-2.0";

  # TODO: Configure more default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "text/plain" = "nvim.desktop";

      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/chrome" = "firefox.desktop";
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
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
      exec = "uwsm stop"; # FIXME: Make this work on KDE too
      icon = "system-users";
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
