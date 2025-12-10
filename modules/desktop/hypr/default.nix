{
  parts.hyprland = {
    tags = ["desktop"];

    nixos = {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      # HACK: This fixes dolphin not seeing file associations in hyprland.
      #       this file is created by kbuildsycoca5 (also overwrites mimeapps.list)
      #       https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/7
      environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };

    hm = {
      pkgs,
      lib,
      host,
      ...
    }: {
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
          "${host.mkNixConfigSymlink ./hypr-conf}/*"
        ];
      };

      programs.waybar = {
        enable = true;
        # WARN: `style` changes behavior depending on whether a path/derivation or a string is passed.
        # To use a symlink here, the output of mkNixConfigSymlink needs to be symlinked again!
        style = ./waybar.css;
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
            if host.laptop.enable
            then modules
            else lib.lists.remove "group/energy" modules;

          include = [(toString (host.mkNixConfigSymlink ./waybar.mainbar.jsonc))];
        };
      };

      services.swaync.enable = true;

      # Override home-manager's config file
      # # NOTE: services.swaync.settings will not work.
      xdg.configFile."swaync/config.json" = lib.mkForce {
        source = host.mkNixConfigSymlink ./swaync.json;
      };

      # TODO: Configure this
      # https://github.com/ErikReider/SwayNotificationCenter/discussions/183
      # TODO: Make this work together with hm's css by importing (like with hyprland.conf)
      xdg.configFile."swaync/style.css" = {
        source = host.mkNixConfigSymlink ./swaync.css;
      };
    };
  };
}
