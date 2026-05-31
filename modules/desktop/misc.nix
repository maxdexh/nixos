{
  parts.desktop-misc = {
    enableIf.tags.fullDesktop = true;

    nixos = {pkgs, ...}: {
      # HACK: This fixes dolphin not seeing file associations in hyprland.
      #       this file is created by kbuildsycoca5 (also overwrites mimeapps.list)
      #       https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/7
      environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      #virtualisation.docker.enable = true;
      #users.extraGroups.docker.members = ["max"];

      #virtualisation.virtualbox.host.enable = true;
      #users.extraGroups.vboxusers.members = ["max"];

      services.ratbagd.enable = true; # For piper
      environment.systemPackages = [pkgs.distrobox pkgs.piper];

      programs.noisetorch.enable = true;

      services.xserver.enable = true;

      fonts.packages = [
        pkgs.nerd-fonts.caskaydia-mono
        pkgs.nerd-fonts.hack
        pkgs.font-awesome
      ];

      programs.dconf.enable = true;
    };

    hm = {
      pkgs,
      lib,
      host,
      ...
    }: {
      xdg.enable = true;

      # HACK: Hotfix for cursor theme not working in steam.
      # https://github.com/ValveSoftware/steam-for-linux/issues/11484#issuecomment-3437303820
      xdg.dataFile."icons/default" = {
        source = "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors/";
        recursive = true;
      };

      # Basic profile with better appearance and using fish shell
      xdg.dataFile."konsole/custom.profile".source = host.mkNixConfigSymlink ./konsole-custom.profile;

      custom.sessionVars = {
        # gtk.theme is dysfunctional, but this works nicely, except that it still has window decorations.
        GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

        # Make electron apps use wayland directly rather than running through xwayland
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        # No idea what this was, i think it had to do with electron using wayland too?
        NIXOS_OZONE_WL = "1";

        SUDO_ASKPASS = let
          askpass = pkgs.writeShellApplication {
            name = "askpass";
            runtimeInputs = [pkgs.rofi];
            text = ''
              rofi -theme material -dmenu -password -p "Password" -l 0 -theme-str 'mainbox { children: [inputbar]; }'
            '';
          };
        in
          lib.getExe askpass;

        TERMINAL = "kitty";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/plain" = "nvim.desktop";
          "application/pdf" = "firefox.desktop";
        };
        defaultApplicationPackages = [
          pkgs.firefox
          pkgs.kdePackages.dolphin
          pkgs.kdePackages.ark
          pkgs.kdePackages.gwenview
          pkgs.vlc
        ];
      };
    };
  };
}
