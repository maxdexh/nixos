modArgs @ {
  lib,
  inputs,
  ...
}: let
  # TODO: Let the host configure how to setup users by default
  hostTy = args @ {
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
        type = lib.types.attrsOf (lib.types.submodule (userTy args));
      };
      configLocation = lib.mkOption {
        type = lib.types.path;
        default = "${inputs.self}";
      };

      nixConfigLocation = lib.mkOption {
        type = lib.types.path;
        default = inputs.self.outPath;
      };

      tags = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
      };
      stateVersion = lib.mkOption {
        type = lib.types.uniq lib.types.str;
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

      checkCond = lib.mkOption {
        readOnly = true;
        default = cond: modArgs.config.lib.checkCond cond config;
      };
    };

    config = let
      filteredParts =
        builtins.filter
        (part: config.checkCond part.enableIf)
        (builtins.attrValues modArgs.config.parts);

      modKinds = builtins.zipAttrsWith (_: lib.mkMerge) filteredParts;

      users = builtins.attrValues config.users;
      mkUserAttrs = mkValue: builtins.listToAttrs (
        map (user: {
          name = user.username;
          value = mkValue user;
        }) users
      );
    in {
      nixos.module = lib.mkMerge [
        modKinds.nixos
        {
          networking.hostName = config.name;
          system.name = config.name;
          system.stateVersion = config.stateVersion;

          users.users = mkUserAttrs (user: lib.mkMerge [
            {
              description = lib.mkDefault user.username;
              name = user.username;
              home = user.homeDirectory;
            }
            user.nixos.user
          ]);
          home-manager.users = mkUserAttrs (user: user.hm.module);
        }
      ];

      hm.shared.module = lib.mkMerge [
        modKinds.hm
        {
          home.stateVersion = config.stateVersion;
        }
      ];
    };
  };

  userTy = hostArgs: {
    config,
    name,
    ...
  }: {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.username}";
      };

      hm.module = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
      nixos = {
        user = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          # TODO: A defaultExtraGroups option would be nice
          # NOTE: Must be set explicitly, either isNormalUser or isSystemUser (see nixos docs)
        };
      };

      host = lib.mkOption {
        readOnly = true;
        default = hostArgs.config;
      };
    };
    config = {
      hm.module = lib.mkMerge [
        hostArgs.config.hm.shared.module
        {
          home = {
            username = config.username;
            homeDirectory = config.homeDirectory;
          };
        }
      ];
    };
  };
in {
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule hostTy);
  };
  options.shared = {
    nixos = {
      module = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
    hm = {
      module = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
      };
    };
  };
}
