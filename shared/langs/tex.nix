{
  pkgs,
  ctx,
  ...
}: ctx.hm.set {
  home.packages = with pkgs; [
    texliveFull
  ];
}
