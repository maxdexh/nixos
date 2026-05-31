{
  parts.display-manager = {
    enableIf.tags.fullDesktop = true;

    nixos = {pkgs, ...}: {
      services.displayManager = {
        defaultSession = "hyprland-uwsm";
      };

      # TODO: https://www.reddit.com/r/NixOS/comments/1qo9alr/need_help_with_gdmhyprlanduwsm_problem/
      services.displayManager.gdm.enable = true;

      # HACK: https://github.com/nixos/nixpkgs/issues/523332
      # FIXME: Remove once fixed
      environment.sessionVariables.XDG_DATA_DIRS = ["${pkgs.gdm}/share"];
      services.displayManager.gdm.settings.debug.Enable = true;
      environment.systemPackages = [pkgs.gnome-session];

      #services.displayManager.sddm = {
      #  wayland.enable = true;
      #  enable = true;
      #};
    };
  };
}
