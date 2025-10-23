{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.user.sessionVariables = {
    # gtk.theme is dysfunctional, but this works nicely, except that it still has window decorations.
    GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

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
}
