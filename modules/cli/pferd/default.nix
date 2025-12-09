{
  pkgs-unstable,
  custom,
  ctx,
  ...
}: ctx.hm.set {
  xdg.configFile."PFERD/pferd.cfg".source = custom.lib.mkNixConfigSymlink ./pferd.cfg;

  home.packages = [pkgs-unstable.pferd];
}
