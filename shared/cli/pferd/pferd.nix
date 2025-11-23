{
  pkgs-unstable,
  config,
  ctx,
  ...
}: ctx.hm.set {
  xdg.configFile."PFERD/pferd.cfg".source = config.lib.custom.mkNixConfigSymlink ./pferd.cfg;

  home.packages = [pkgs-unstable.pferd];
}
