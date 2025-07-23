{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
    hyprshot
    brightnessctl
    rofi-wayland
    xorg.xrdb # For kde-style xwayland scaling
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # TODO: https://wiki.nixos.org/wiki/Hyprland config is nix
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  xdg.desktopEntries = {
    hibernate = {
      name = "Hibernate";
      exec = "systemctl hibernate";
      # icon = "hibernate";
      genericName = "Hibernate";
    };
    suspend = {
      name = "Suspend";
      exec = "systemctl suspend-then-hibernate";
      # icon = "suspend";
      genericName = "Put System to Sleep";
    };
    shutdown = {
      name = "Shut Down";
      exec = "shutdown -h now";
      # icon = "poweroff";
      genericName = "Power off the System";
    };
    reboot = {
      name = "Reboot";
      exec = "reboot";
      # icon = "restart";
      genericName = "Restart the System";
    };
    logout = {
      name = "Log out";
      # TODO: More graceful, universal command
      exec = "hyprctl dispatch exit";
      comment = "Exit Desktop";
    };

    networkconfig = {
      name = "Network";
      exec = "plasmawindowed org.kde.plasma.networkmanagement";
      icon = "settings";
      genericName = "Plasma Network Config";
    };
    bluetooth = {
      name = "Bluetooth";
      exec = "plasmawindowed org.kde.plasma.bluetooth";
      icon = "bluetooth";
      genericName = "Plasma Bluetooth Config";
    };
    volume = {
      name = "Audio";
      # exec = "plasmawindowed org.kde.plasma.volume";
      exec = "kcmshell6 kcm_pulseaudio"; # NOTE:
      icon = "preferences-desktop-sound";
      genericName = "Plasma Sound Config";
    };
  };
}
