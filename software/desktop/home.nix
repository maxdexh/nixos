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
}
