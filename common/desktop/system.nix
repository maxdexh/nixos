# FIXME: How much of this config only works properly because of plasma6.enable = true?
{pkgs, ...}: {
  qt = {
    # TODO: How to configure light/dark theme for qt?
    enable = true;
    style = "breeze";
    platformTheme = "kde6";
  };

  services.ratbagd.enable = true; # For piper
  environment.systemPackages = with pkgs; [piper];

  services.xserver.enable = true;

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    # autoLogin = {
    #   enable = true;
    #   user = "max";
    # };
  };
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    # settings = {
    #   greeter = {
    #     IncludeAll = true;
    #   };
    # };
  };

  # NOTE:
  # - sddm password login takes ~30s if biometrics are available (https://github.com/sddm/sddm/issues/284)
  # - sddm sometimes often for login twice
  # - try https://invent.kde.org/plasma/plasma-login-manager once it's ready
  # services.displayManager.sddm.enable = true;

  fonts.packages = with pkgs; [
    # cascadia-code
    nerd-fonts.caskaydia-mono
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  programs.dconf.enable = true;

  # Adwaita-Dark doesnt seem to do anything and breeze-dark (using breeze-gtk pkg) is completely broken
  # Luckily the GTK_THEME variable works flawlessly for both themes, see ./home.nix
  # gtk = {
  #   enable = true;
  #   theme = { name = "Adwaita-Dark"; };
  #   gtk3 = { extraConfig.gtk-application-prefer-dark-theme = true; };
  # };
}
