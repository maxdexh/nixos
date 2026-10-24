{
  parts.documentation-man = {
    enableIf.tags.nixos = true;

    nixos = {pkgs, ...}: {
      documentation.man = {
        cache = {
          enable = true;
          generateAtRuntime = true;
        };
      };
      environment.systemPackages = with pkgs; [
        # linux-manual # FIXME: This fails to build lmao
        man-pages
        man-pages-posix
      ];
    };
  };
}
