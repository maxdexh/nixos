{
  pkgs,
  ctx,
  ...
}: ctx.os.set {
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
