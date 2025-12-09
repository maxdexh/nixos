{
  pkgs-unstable,
  host,
  ctx,
  ...
}: ctx.hm.set {
  xdg.configFile."PFERD/pferd.cfg".source = host.mkNixConfigSymlink ./pferd.cfg;

  home.packages = [pkgs-unstable.pferd];
}
