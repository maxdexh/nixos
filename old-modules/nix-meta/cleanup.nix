{ctx, ...}:
ctx.hm.set {
  programs.nh = {
    enable = true;
    clean = {
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 14d --optimise";
    };
  };
}
