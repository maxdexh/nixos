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
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
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
      laptop.enable = lib.mkEnableOption "laptop";
      cliOnly.enable = lib.mkEnableOption "cli config only";

      usIsoLayout = {
        enable = lib.mkEnableOption "US ISO Keyboard Layout";
        remaps = lib.mkEnableOption "US ISO Keyboard Remaps";
      };

      fullDesktop = lib.mkEnableOption "Whether a full desktop environment is available";

      nixConfigLocation = lib.mkOption {
        type = lib.types.path;
        default = inputs.self.outPath;
      };

      nixos = {
        enable = lib.mkEnableOption "nixos";
        extraModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
        };
        tags = lib.mkOption {
          type = lib.types.attrsOf lib.types.bool;
        };
      };
      sharedHmModules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
      };
    };
    config = {
      fullDesktop = lib.mkDefault (!config.cliOnly.enable);
    };
  });
in {
  options = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf host_type;
    };
  };
}
