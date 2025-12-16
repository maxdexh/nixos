{lib, ...}: let
  # TODO: Figure out a way to wrap modules in mkIf
  part_type = {name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        readOnly = true;
      };

      # TODO:
      # - Require predefining tags, checked lookup of tags in attrset
      # - Instead use `enableIf` attribute with sum types representing conditions
      #   - Condition.oneOf
      #   - Condition.allOf
      #   - Condition.not
      #   - Condition.checkHost (with helpers for hostname with existence check, ifNixos, hasPart, etc.)
      #   - Condition.tag (simple objects, created via options)
      #   - `true`/`false`
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      nixos = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      hm = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      # FIXME: Do this with tags instead?
      nixosOrHm = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
  };
in {
  options.defaultTags = lib.mkOption {
    type = lib.types.attrsOf (lib.types.nullOr lib.types.bool);
    default = {};
  };
  options.parts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.uniq (lib.types.submodule part_type));
    default = {};
  };
}
