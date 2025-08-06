{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # HACK: This fixes dolphin not seeing file associations in hyprland.
  #       this file is created by kbuildsycoca5 (also overwrites mimeapps.list)
  #       https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/7
  environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
