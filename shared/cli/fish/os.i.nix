{
  pkgs,
  ctx,
  ...
}: ctx.os.set {
  environment.systemPackages = with pkgs; [fish];
}
