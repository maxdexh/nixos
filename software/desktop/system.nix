{pkgs, ...}: {
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde6";
  };

  fonts.packages = with pkgs; [
    # cascadia-code
    nerd-fonts.caskaydia-mono
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # Adwaita-Dark doesnt seem to do anything and breeze-dark (using breeze-gtk pkg) is completely broken
  # Luckily the GTK_THEME variable works flawlessly for both themes, see ./home.nix
  # gtk = {
  #   enable = true;
  #   theme = { name = "Adwaita-Dark"; };
  #   gtk3 = { extraConfig.gtk-application-prefer-dark-theme = true; };
  # };
}
