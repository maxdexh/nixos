{
  parts.pferd = {
    tags = ["personal"];

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
