{lib, ...}: let
  # TODO: Figure out a way to wrap modules in mkIf
  partTy = {name, ...}: {
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
      enable = lib.mkOption {
        type = condTy;
      };

      nixos = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      # FIXME: Allow the same part to have multiple submodules with different conditions
      # FIXME: This does not give a way to filter by users
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

  condDeclTy = lib.types.attrTag {
    noneOf = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    oneOf = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    allOf = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    anyOf = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    not = lib.mkOption {
      type = condTy;
    };

    tag = lib.mkOption {
      type = lib.types.submodule {
        options.name = lib.mkOption {
          type = lib.types.str; # TODO: Constrain to declared tags
        };
      };
    };

    checks = lib.mkOption {
      type = lib.types.submodule {
        host = lib.mkOption {
          type = lib.uniq (lib.types.functionTo lib.types.bool);
        };
        user = lib.mkOption {
          type = lib.uniq (lib.types.functionTo lib.types.bool);
        };
      };
    };

    hostCheck = lib.mkOption {
      type = lib.uniq (lib.types.functionTo lib.types.bool);
    };
    userCheck = lib.mkOption {
      type = lib.uniq (lib.types.functionTo lib.types.bool);
    };
  };

  condTy = lib.types.either lib.types.bool condDeclTy;
in {
  options.defaultTags = lib.mkOption {
    type = lib.types.attrsOf (lib.types.nullOr lib.types.bool);
    default = {};
  };

  options = {
    parts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.uniq (lib.types.submodule partTy));
      default = {};
    };

    tags = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          name = lib.mkOption {
            readOnly = true;
            default = name;
          };
          default = lib.mkOption {
            type = lib.types.bool;
          };
        };
      }));
    };

    conds = lib.mkOption {
      type = lib.types.attrsOf condDeclTy;
    };
  };
}
