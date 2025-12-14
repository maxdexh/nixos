{
  parts.nixld = {
    tags = ["default"];

    nixos = {pkgs, ...}: {
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        libudev-zero
        libudev0-shim
        linuxHeaders
        libGL
        nas
        SDL2
      ];
      environment.systemPackages = with pkgs; [
        SDL2
      ];
    };
  };
}
