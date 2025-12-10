{lib, ...}: let
  part_type = {name, ...}: {
    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      readOnly = true;
    };
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    nixos = lib.mkOption {
      type = lib.types.deferredModule;
      default = {};
    };
    hm = lib.mkOption {
      type = lib.type.deferredModule;
      default = {};
    };
  };
in {
  options.parts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule part_type);
  };
}
