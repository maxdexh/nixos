{
  pkgs,
  lib,
  custom,
  ctx,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf custom.host.fullDesktop)
] [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [kitty];
  })

  (ctx.hm.set {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = "include ${custom.lib.mkNixConfigSymlink ./kitty.conf}";
    };

    home.packages = with pkgs; [
      tdf
    ];
  })
]
