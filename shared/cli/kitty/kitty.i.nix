{
  pkgs,
  lib,
  config,
  ctx,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf config.custom.host.fullDesktop)
] [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [kitty];
  })

  (ctx.hm.set {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = "include ${config.lib.custom.mkNixConfigSymlink ./kitty.conf}";
    };

    home.packages = with pkgs; [tdf];
  })
]
