{
  pkgs,
  ctx,
  ...
}: ctx.os.set {
  environment.systemPackages = with pkgs; [
    # NOTE: Currently only login works via fprint (unless using pin), see https://www.reddit.com/r/Bitwarden/comments/1myd5qc/biometric_login_greyed_out_in_bitwarden_windows/
    # TODO: Try again once it becomes usable
    bitwarden-desktop
  ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
// ctx.hm.set {
  services.hyprpolkitagent.enable = true;
}
