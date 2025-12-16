{
  parts.nixld = {
    tags = ["personal"];

    nixos = {pkgs, ...}: {
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        udev
        libudev-zero
        libudev0-shim
        linuxHeaders
        libGL
        nas
        SDL2
        cairo
        librsvg
      ];
      environment.systemPackages = with pkgs; [
        SDL2
      ];
    };
  };
}
