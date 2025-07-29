{ lib, ... }:

{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css;
  };

  # FIXME: Icons have inconsistent sizes, shifting around the UI
  programs.waybar.settings.mainBar = {
    reload_style_on_change = true;

    position = "bottom";
    modules-left = [ "hyprland/workspaces" ];
    modules-right = let
      modules = [
        "tray"

        "pulseaudio#mic"
        "pulseaudio#out"

        "group/energy"

        "clock"
      ];
      # TODO: Check if host is a laptop
    in if true then modules else lib.lists.remove "group/energy" modules;

    # TODO: Make this not suck
    "hyprland/workspaces" = {
      format = "{icon}";
      on-scroll-up = "hyprctl dispatch workspace e+1";
      on-scroll-down = "hyprctl dispatch workspace e-1";
    };
    "clock" = {
      format = "{:%H:%M %d/%m}";
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
    "group/energy" = {
      orientation = "inherit";
      modules = [ "power-profiles-daemon" "battery" ];
    };
    # TODO: Padding to prevent shifting text
    battery = {
      interval = 30;
      format = "{capacity}% -{power:3.1f}W";
      format-charging = "{capacity}% +{power:3.1f}W";
      format-plugged = "{format_charging}";
    };
    power-profiles-daemon = {
      format = "{icon} ";
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
}
