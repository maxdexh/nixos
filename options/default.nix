{lib, ...}: {
  imports = [
    ./hosts.nix
    ./parts.nix
    ./overlays.nix
  ];

  options.lib = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;
    };
  };
}
