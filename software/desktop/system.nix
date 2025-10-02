# FIXME: How much of this config only works properly because of plasma6.enable = true?
{pkgs, ...}: {
  qt = {
    # TODO: How to configure light/dark theme for qt?
    enable = true;
    style = "breeze";
    platformTheme = "kde6";
  };

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # FIXME: sddm doesn't unlock gnome-keyring
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
