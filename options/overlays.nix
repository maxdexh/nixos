{lib, ...}: {
  # TODO: Merge overlays
  options.globalOverlays = lib.mkOption {
    # https://github.com/NixOS/nixpkgs/blob/09eb77e94fa25202af8f3e81ddc7353d9970ac1b/nixos/modules/misc/nixpkgs.nix#L47
    type = lib.types.attrsOf (lib.mkOptionType {
      name = "nixpkgs-overlay";
      description = "nixpkgs overlay";
      check = lib.isFunction;
      merge = lib.mergeOneOption;
    });
    default = {};
  };
}
