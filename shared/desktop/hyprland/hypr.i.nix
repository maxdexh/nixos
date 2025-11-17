{
  pkgs,
  lib,
  config,
  ctx,
  host,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf config.custom.host.fullDesktop)
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
      waybar
      hyprshot
      hyprpicker
      brightnessctl
      rofi-wayland
      xorg.xrdb # For kde-style xwayland scaling
      killall
      playerctl
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      # Put the `source =` declarations at the end of the generated hyprland.conf,
      # such that we can pass variables from the nix config
      sourceFirst = false;

      settings = lib.mkMerge [
        {
          source = [
            "${config.lib.custom.mkNixConfigSymlink ./hypr-conf}/*"
            "${config.lib.custom.mkNixConfigSymlink host.hyprHostConf}"
          ];
        }
      ];
    };

    programs.waybar = {
      enable = true;
      style = config.lib.custom.mkNixConfigSymlink ./waybar.css;
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
          if config.custom.host.laptop.enable
          then modules
          else lib.lists.remove "group/energy" modules;

        include = [(toString (config.lib.custom.mkNixConfigSymlink ./waybar.mainbar.jsonc))];
      };
    };

    services.swaync = {
      enable = true;
      package = let
        base = pkgs.swaynotificationcenter;
        mainExe = lib.getExe base;
        mainExeName = builtins.baseNameOf mainExe;

        # Patch swaync to do nothing under KDE
        # https://discourse.nixos.org/t/tip-how-to-enable-dunst-for-only-select-des-with-nix/65630
        patched = pkgs.writeShellScriptBin mainExeName ''
          if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
            echo "SwayNC: Not starting because session is KDE Plasma."
            exit 0
          fi
          exec ${mainExe} "$@"
        '';
      in
        pkgs.symlinkJoin {
          name = "swaync-kde-patch";
          paths = [patched base]; # NOTE: patched shadows base
          meta = base.meta;
        };
    };

    # Override home-manager's config file # NOTE: services.swaync.settings will not work.
    xdg.configFile."swaync/config.json" = lib.mkForce {
      source = config.lib.custom.mkNixConfigSymlink ./swaync.json;
    };

    # TODO: Configure this
    # https://github.com/ErikReider/SwayNotificationCenter/discussions/183
    # TODO: Make this work together with hm's css by importing (like with hyprland.conf)
    xdg.configFile."swaync/style.css" = {
      source = config.lib.custom.mkNixConfigSymlink ./swaync.css;
    };
  })
]
