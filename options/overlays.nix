{lib, ...}: {
  # TODO: Merge overlays
  options.overlays = lib.mkOption {
    type = lib.types.atrrsOf lib.types.anything;
    default = {};
  };
}
