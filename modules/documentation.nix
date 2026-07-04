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
      environment.systemPackages = with pkgs; [linux-manual man-pages man-pages-posix];
    };
  };
}
