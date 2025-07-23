{ ... }:

{
  home.sessionVariables = {
    # gtk.theme is dysfunctional, but this works nicely
    # It still has window decorations though.
    GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

    # Make electron apps use wayland directly rather than running through xwayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # No idea what this was, i think it had to do with electron using wayland too?
    NIXOS_OZONE_WL = "1";
  };
}
