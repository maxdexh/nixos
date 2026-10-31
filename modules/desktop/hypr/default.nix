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
      config,
      inputs,
      ...
    }: let
      scratchbar = inputs.scratchbar.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in {
      home.packages = with pkgs; [
        hyprpicker
        brightnessctl
        xrdb # For kde-style xwayland scaling
        killall
        playerctl
        scratchbar
      ];

      programs.rofi.enable = true;
      programs.hyprshot.enable = true;

      custom.sessionVars = {
        # See .emmyrc.json
        HYPRLAND_STUBS_PATH = "${pkgs.hyprland}/share/hypr/stubs";
      };

      xdg.configFile = {
        "hypr/conf".source = host.mkNixConfigSymlink ./conf;
        "hypr/hosts".source = host.mkNixConfigSymlink ./hosts;
      };
      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = /*lua*/ ''
          require("conf.hyprland")
          require("hosts.${host.name}.hyprland")
        '';
      };

      # TODO: Write nixosModules for this
      systemd.user.services.scratchbar = {
        Unit = {
          Description = "scratchbar";
          PartOf = [config.wayland.systemd.target];
          After = [config.wayland.systemd.target];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };

        Service = {
          ExecStart = lib.getExe scratchbar;
          Restart = "on-failure";
        };

        Install.WantedBy = [config.wayland.systemd.target];
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
