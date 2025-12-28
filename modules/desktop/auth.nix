{
  parts.desktop-auth = {
    enableIf.tags.fullDesktop = true;

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        bitwarden-desktop
      ];

      # services.gnome.gnome-keyring.enable = true;
      # security.pam.services.login.enableGnomeKeyring = true;
    };

    hm = {
      services.hyprpolkitagent.enable = true;
    };
  };
}
