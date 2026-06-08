{
  parts.hyprland = {
    enableIf.tags.fullDesktop = true;

    nixos = {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
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
        xrdb # For kde-style xwayland scaling
        killall
        playerctl
      ];

      programs.rofi.enable = true;
      programs.hyprshot.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";

        # FIXME: Add a custom option that specifies list of dirs/files to import from, with proper escaping
        extraConfig = let
          place = ./hypr-conf;
          files = builtins.attrNames (builtins.readDir place);
          luaFiles = builtins.filter (lib.hasSuffix ".lua") files;
          basePath = host.mkNixConfigSymlink place;
          to_import = f: "dofile('${basePath}/${f}')\n";
        in builtins.concatStringsSep "" (map to_import luaFiles);
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
            if host.checkCond {tags.laptop = true;}
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
