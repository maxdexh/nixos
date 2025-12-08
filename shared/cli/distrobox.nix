{
  pkgs,
  ctx,
  ...
}: ctx.os.set {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = [pkgs.distrobox]; # TODO: programs.distrobox
}
