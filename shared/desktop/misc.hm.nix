{
  pkgs,
  lib,
  config,
  ...
}: {
  xdg.enable = true;

  # HACK: Hotfix for cursor theme not working in steam.
  # https://github.com/ValveSoftware/steam-for-linux/issues/11484#issuecomment-3437303820
  home.file.".local/share/icons/default" = lib.mkIf config.custom.host.fullDesktop {
    source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors/";
    recursive = true;
  };

  custom.sessionVars = lib.mkIf config.custom.host.fullDesktop {
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
  };

  # TODO: Configure more default apps
  xdg.mimeApps = lib.mkIf config.custom.host.fullDesktop {
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
