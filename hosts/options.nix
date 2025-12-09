{
  inputs,
  lib,
  config,
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
  base_config = config;

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
      nixos = {
        enable = lib.mkEnableOption "nixos";
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
        };
      };
      users = lib.mkOption {
        type = lib.types.attrsOf user_type;
        default = base_config.defaultUsers;
      };
      homeBase = lib.mkOption {
        type = lib.types.path;
        default = "/home";
      };
      configLocation = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.self}";
      };
      sharedHmModules = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
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
    };
    config = {
      fullDesktop = lib.mkDefault (!config.cliOnly.enable);
    };
  });
in {
  options = {
    defaultUsers = lib.mkOption {
      type = lib.types.attrsOf user_type;
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf host_type;
    };
  };
}
