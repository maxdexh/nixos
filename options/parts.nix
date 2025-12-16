{
  lib,
  config,
  ...
}: let
  # TODO: Figure out a way to wrap modules in mkIf
  partTy = {name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        readOnly = true;
      };

      enableIf = lib.mkOption {
        type = condTy;
      };

      nixos = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      # FIXME: Allow the same part to have multiple submodules with different conditions (needs nice api first)
      # FIXME: This does not give a way to filter by users
      hm = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
  };

  checkCond = let
    byTag = {
      check = checkFn: checkFn;
      all = conds: arg: builtins.all (cond: checkCond cond arg) conds;
      any = conds: arg: builtins.any (cond: checkCond cond arg) conds;
      not = cond: arg: !checkCond cond arg;
      tags = tagset: arg: assert tagset != {}; let
        checkTag = {
          name,
          value,
        }: let
          defaultCond = config.tags.${name}.default or (throw "${arg.name or arg.username} must define a default for tag '${name}'");
          default = checkCond defaultCond arg;
          tagValue = arg.tags.${name} or default;
        in value == tagValue;
      in
        builtins.all checkTag (lib.attrsToList tagset);
    };
  in cond: arg:
    if builtins.isBool cond
    then cond
    else
      builtins.all (
        {
          name,
          value,
        }: byTag.${name} value arg
      ) (assert cond != {}; lib.attrsToList cond);

  condDeclTy = lib.types.attrTag {
    check = lib.mkOption {
      type = lib.uniq (lib.types.functionTo lib.types.bool);
    };
    all = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    any = lib.mkOption {
      type = lib.types.listOf condTy;
    };
    not = lib.mkOption {
      type = condTy;
    };
    tags = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
    };
  };

  condTy = lib.types.either lib.types.bool condDeclTy;
in {
  config.lib = {
    inherit condTy checkCond;
  };

  options = {
    parts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.uniq (lib.types.submodule partTy));
      default = {};
    };

    # FIXME: Differentiate user and host tags.
    tags = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          name = lib.mkOption {
            readOnly = true;
            default = name;
          };
          default = lib.mkOption {
            type = condTy;
          };
          # disableOverride =
          # conficts =
        };
      }));
    };
  };
}
