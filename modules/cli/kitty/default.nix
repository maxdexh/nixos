{
  parts.kitty = {
    enableIf.tags.desktop = true;

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.kitty];
    };

    hm = {
      pkgs,
      host,
      ...
    }: {
      programs.kitty = {
        enable = true;
        enableGitIntegration = true;
        extraConfig = "include ${host.mkNixConfigSymlink ./kitty.conf}";
      };

      home.packages = [
        pkgs.tdf
      ];
    };
  };
}
