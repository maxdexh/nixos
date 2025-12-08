{
  pkgs,
  lib,
  custom,
  ctx,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf custom.host.fullDesktop)
] [
  (ctx.os.set {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # HACK: This fixes dolphin not seeing file associations in hyprland.
    #       this file is created by kbuildsycoca5 (also overwrites mimeapps.list)
    #       https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/7
    environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  })

  (ctx.hm.set {
    home.packages = with pkgs; [
      hyprpicker
      brightnessctl
      xorg.xrdb # For kde-style xwayland scaling
      killall
      playerctl
    ];

    programs.rofi.enable = true;
    programs.hyprshot.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      # Put the `source =` declarations at the end of the generated hyprland.conf,
      # such that we can pass variables from the nix config
      sourceFirst = false;

      settings.source = [
        "${custom.lib.mkNixConfigSymlink ./hypr-conf}/*"
      ];
    };

    programs.waybar = {
      enable = true;
      style = custom.lib.mkNixConfigSymlink ./waybar.css;
      settings.mainBar = {
        modules-left = ["hyprland/workspaces"];

        modules-right = let
          modules = [
            "tray"

            "pulseaudio#mic"
            "pulseaudio#out"

            "group/energy"

            "clock"
          ];
        in
          if custom.host.laptop.enable
          then modules
          else lib.lists.remove "group/energy" modules;

        include = [(toString (custom.lib.mkNixConfigSymlink ./waybar.mainbar.jsonc))];
      };
    };

    services.swaync.enable = true;

    # Override home-manager's config file # NOTE: services.swaync.settings will not work.
    xdg.configFile."swaync/config.json" = lib.mkForce {
      source = custom.lib.mkNixConfigSymlink ./swaync.json;
    };

    # TODO: Configure this
    # https://github.com/ErikReider/SwayNotificationCenter/discussions/183
    # TODO: Make this work together with hm's css by importing (like with hyprland.conf)
    xdg.configFile."swaync/style.css" = {
      source = custom.lib.mkNixConfigSymlink ./swaync.css;
    };
  })
]
