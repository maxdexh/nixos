{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./waybar.nix];
  home.packages = with pkgs; [
    waybar
    hyprshot
    hyprpicker
    brightnessctl
    rofi-wayland
    xorg.xrdb # For kde-style xwayland scaling
    killall
    playerctl

    # These packages are required for kcmshell to work
    kdePackages.kirigami-addons
    kdePackages.kitemmodels
    kdePackages.kdeclarative
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    sourceFirst = false;

    settings = {
      "$terminal" = "kitty";
      source = ["${config.lib.file.symlinkNixConfig ./hypr-conf}/*"];
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
    source = config.lib.file.symlinkNixConfig ./swaync.json;
  };

  # TODO: Configure this
  # https://github.com/ErikReider/SwayNotificationCenter/discussions/183
  # TODO: Make this work together with hm's css by importing (like with hyprland.conf)
  xdg.configFile."swaync/style.css" = {
    source = config.lib.file.symlinkNixConfig ./swaync.css;
  };
}
