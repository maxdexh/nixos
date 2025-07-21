{
  enable = true;
  settings = {
    mainBar = {
      position = "bottom";
      modules-left = [ "hyprland/workspaces" ];
      modules-right = [
        "tray"
        "power-profiles-daemon"
        "pulseaudio#mic"
        "pulseaudio#out"
        "battery"
        "clock#date"
        "clock#time"
        "custom/notification"
      ];

      # TODO: Make this not suck
      "hyprland/workspaces" = {
        format = "{icon}";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      "clock#date" = {
        format = "{:%d/%m}";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>
        '';
      };
      "clock#time" = {
        format = "{:%H:%M}";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>
        '';
      };
      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-full = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = ''
          Power profile: {profile}
          Driver: {driver}
        '';
        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };
      "pulseaudio#mic" = {
        format = "{format_source}";
        format-source = " {volume}%";
        format-source-muted = " {volume}%";
        on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
        on-click-right = "pactl set-source-volume @DEFAULT_SOURCE@ 100%";
        on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
        on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
      };
      "pulseaudio#out" = {
        format = "{icon} {volume}%";
        format-muted = " {volume}%"; # TODO: Mute symbol
        format-bluetooth = "{icon} {volume}%";
        format-bluetooth-muted = " {volume}%"; # TODO: Mute symbol
        format-icons = {
          # headphone = "";
          # hands-free = "";
          # headset = "";
          # phone = "";
          # portable = "";
          # car = "";
          default = [ "" "" "" ];
        };
        on-click = "wpctl set-mute @DEFAULT_SINK@ toggle";
      };
      tray = { spacing = 10; };
    };
  };
  style = builtins.readFile ./waybar/style.css;
}
