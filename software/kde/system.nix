{pkgs, ...}: {
  # services.xserver.displayManager.gdm = {
  #   enable = true;
  #   wayland = true;
  # };

  # FIXME: Make sddm unlock gnome keyring
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    kwalletmanager
    okular
    kwallet
    kwallet-pam
  ];
}
