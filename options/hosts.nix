{
  inputs,
  lib,
  ...
}: let
  user_type = lib.types.submodule ({name, ...}: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      # FIXME: Use tags
      hm.module = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
  });

  host_type = lib.types.submodule ({
    name,
    config,
    ...
  }: {
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
        type = lib.types.attrsOf user_type;
      };
      configLocation = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.self}";
      };
      # FIXME: Use tags
      laptop.enable = lib.mkEnableOption "laptop";
      # FIXME: Use tags
      cliOnly.enable = lib.mkEnableOption "cli config only";

      # FIXME: Use tags
      usIsoLayout = {
        enable = lib.mkEnableOption "US ISO Keyboard Layout";
        remaps = lib.mkEnableOption "US ISO Keyboard Remaps";
      };

      # FIXME: Use tags
      fullDesktop = lib.mkEnableOption "Whether a full desktop environment is available";

      nixConfigLocation = lib.mkOption {
        type = lib.types.path;
        default = inputs.self.outPath;
      };

      tags = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = {};
      };
      nixos = {
        enable = lib.mkEnableOption "nixos";
        # FIXME: Use tags
        module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      };
      hm = {
        # FIXME: Use tags
        sharedModule = lib.mkOption {
          type = lib.types.deferredModule;
          default = {};
        };
      };
    };
    config = {
      fullDesktop = lib.mkDefault (!config.cliOnly.enable);
    };
  });
in {
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf host_type;
  };
}
