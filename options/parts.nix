{lib, ...}: let
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
      #   - Condition.checkHost
      #   - Condition.tag
      #   - `true`
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      # NOTE: do not touch the types of these,
      # it can break things like `pkgs` being
      # passed to modules and `mkForce` will
      # stop working
      nixos = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      hm = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
  };
in {
  # TODO: Extend tag system to general host -> bool functions
  # TODO: Allow depending on other tag values, including host's
  options.defaultTags = lib.mkOption {
    type = lib.types.attrsOf (lib.types.nullOr lib.types.bool);
    default = {};
  };
  options.parts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.uniq (lib.types.submodule part_type));
    default = {};
  };
}
