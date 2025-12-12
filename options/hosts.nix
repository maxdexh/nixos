full_args @ {
  inputs,
  lib,
  ...
}: let
  user_type = host_args: lib.types.submodule ({name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      hm.module = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      host = lib.mkOption {
        type = host_type;
        default = host_args.config;
        readOnly = true;
      };
    };
    config = {
      hm.module = host_args.config.hm.shared.module;
    };
  });

  host_type = lib.types.submodule (host_args @ {name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
      };
      users = lib.mkOption {
        type = lib.types.attrsOf (user_type host_args);
      };
      configLocation = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.self}";
      };
      # FIXME: Use tags
      laptop.enable = lib.mkEnableOption "laptop";

      # FIXME: Use tags
      usIsoLayout = {
        enable = lib.mkEnableOption "US ISO Keyboard Layout";
        remaps = lib.mkEnableOption "US ISO Keyboard Remaps";
      };

      nixConfigLocation = lib.mkOption {
        type = lib.types.path;
        default = inputs.self.outPath;
      };

      tags = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
      };
      nixos = {
        enable = lib.mkEnableOption "nixos";
        module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      };
      hm.shared.module = lib.mkOption {
        type = lib.types.deferredModule;
      };
    };

    config = let
      tags = host_args.config.tags;

      all_parts = builtins.attrValues full_args.config.parts;

      filtered_parts = builtins.filter (part: builtins.any (tag: tags.${tag}) part.tags) all_parts;

      parts_attrs_lists = lib.zipAttrs filtered_parts;
    in {
      tags = builtins.mapAttrs (_: lib.mkDefault) full_args.config.defaultTags;
      nixos.module = lib.mkMerge parts_attrs_lists.nixos;
      hm.shared.module = lib.mkMerge parts_attrs_lists.hm;
    };
  });
in {
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf host_type;
  };
}
