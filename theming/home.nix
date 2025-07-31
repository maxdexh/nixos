{ pkgs, ... }:

{
  home.sessionVariables = {
    # gtk.theme is dysfunctional, but this works nicely, except that it still has window decorations.
    GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

    # Make electron apps use wayland directly rather than running through xwayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # No idea what this was, i think it had to do with electron using wayland too?
    NIXOS_OZONE_WL = "1";

    SUDO_ASKPASS = let
      askpass = pkgs.writeShellApplication {
        name = "askpass";
        runtimeInputs = [ pkgs.rofi-wayland ];
        text = ''
          rofi -theme material -dmenu -password -p "Password" -l 0 -theme-str 'mainbox { children: [inputbar]; }'
        '';
      };
    in "${askpass}/bin/askpass";
  };
}
