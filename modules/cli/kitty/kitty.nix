{
  pkgs,
  lib,
  host,
  ctx,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf host.fullDesktop)
] [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [kitty];
  })

  (ctx.hm.set {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = "include ${host.mkNixConfigSymlink ./kitty.conf}";
    };

    home.packages = with pkgs; [
      tdf
    ];
  })
]
