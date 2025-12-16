{
  parts.pferd = {
    enableIf.tags.personal = true;

    hm = {
      unstable,
      host,
      ...
    }: {
      xdg.configFile."PFERD/pferd.cfg".source = host.mkNixConfigSymlink ./pferd.cfg;

      home.packages = [unstable.pferd];
    };
  };
}
