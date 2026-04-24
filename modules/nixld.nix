{
  parts.nixld = {
    enableIf.tags.personal = true;

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
        stdenv.cc.cc
      ];
      environment.systemPackages = with pkgs; [
        SDL2
      ];
    };
  };
}
