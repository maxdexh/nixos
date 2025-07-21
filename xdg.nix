{
  dataFile = {
    # use x86 stable as default
    "rustup/settings.toml".source = ./rustup/settings.toml;
  };
  configFile = {
    # Configure kitty. TODO: This could probably be done here instead
    "kitty".source = ./kitty;

    # Configure nvim. TODO: Probably want to specify a repo or use a submodule instead
    "nvim".source = ./nvim;

    # Configure pferd. TODO: Probably want to specify a repo or use a submodule instead
    "PFERD".source = ./PFERD;
  };
  desktopEntries = {
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
