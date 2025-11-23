{
  pkgs,
  ctx,
  ...
}: ctx.os.set {
  environment.systemPackages = with pkgs; [
    # TODO: home-manager services.hyprpolkitagent?
    hyprpolkitagent

    # NOTE: Currently only login works via fprint (unless using pin), see https://www.reddit.com/r/Bitwarden/comments/1myd5qc/biometric_login_greyed_out_in_bitwarden_windows/
    # NOTE: Use unstable via profile until https://github.com/NixOS/nixpkgs/pull/425477 makes it to stable
    bitwarden-desktop
  ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
