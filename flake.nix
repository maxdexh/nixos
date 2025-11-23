{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nix profile install nixpkgs/nixpkgs-unstable#packagename
    # TODO: Also add overlays to this and make them available
    # like the overlayed nixpks
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    _hosts = {
      fw13 = {
        nixOS = true;
      };
      homepc = {
        nixOS = true;
      };
    };
    _users = {
      max = {};
    };
    hosts = lib.mapAttrsToList (name: {
      modulePaths ? [./hosts/${name}],
      # FIXME: Configure this via options instead
      hyprHostConf ? ./hosts/${name}/hyprland.conf,
      system ? "x86_64-linux",
      nixOS ? false,
      # TODO: Remove
      hmStandalone ? false,
      termux ? false, # NOTE: unimplemented
      usersDir ? (assert !termux; name: "/home/${name}"),
    }: {
      inherit system name nixOS hmStandalone termux usersDir hyprHostConf;
      modulePaths = assert hmStandalone || nixOS; assert !termux; modulePaths ++ [./shared];
    }) _hosts;

    users = lib.mapAttrsToList (name: {}: {
      inherit name;
    }) _users;

    find_auto_imports = typ: basepath: let
      imports = lib.pipe basepath [
        lib.filesystem.listFilesRecursive
        (builtins.filter (path: lib.hasSuffix ".${typ}.nix" (toString path)))
        (map (x: builtins.trace x x))
      ];
      count = builtins.length imports;
    in
      builtins.trace "Importing ${toString count} files of ${configPathToRel basepath}/**.${typ}.nix" imports;

    # Like nixpkgs.legacyPackages, maps systems to packages
    packagesBySystem = lib.pipe hosts [
      (builtins.groupBy (host: host.system))
      (builtins.mapAttrs (system: _: builtins.trace "Importing nixpkgs for ${system}" import inputs.nixpkgs {
        inherit system;
        overlays = map import (find_auto_imports "o" ./overlays);
        config = {
          allowUnfree = true;
        };
      }))
    ];

    mod_kinds = {
      HOME = "hm";
      SYSTEM = "os";
    };

    lib = inputs.nixpkgs.lib;
    cross_lists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f]; # Copy of the deprecated lib.crossLists

    configPathToRel = lib.flip lib.pipe [
      (path: assert builtins.isPath path; path)
      toString
      # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
      # Could also be done without the builtin by traversing backwards using
      # `+ "/.."` and using `baseNameOf` to get each path segment.
      builtins.unsafeDiscardStringContext
      (abs: assert lib.hasPrefix "${inputs.self}/" abs; lib.removePrefix "${inputs.self}/" abs)
    ];

    build_special_args = host: mod_kind: {
      inherit host inputs configPathToRel;
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
      ctx = {
        kind = mod_kind;
        os.set = lib.optionalAttrs (mod_kind == mod_kinds.SYSTEM);
        os.list = lib.optionals (mod_kind == mod_kinds.SYSTEM);
        hm.set = lib.optionalAttrs (mod_kind == mod_kinds.HOME);
      };
    };

    nixos_system = host: let
      auto_imports = host.modulePaths;
    in lib.nixosSystem {
      pkgs = packagesBySystem.${host.system};

      modules = let
        mk_user_sets = mk_val: lib.pipe users [
          (builtins.filter (user: true))
          (map (user: {${user.name} = mk_val user;}))
          lib.attrsets.mergeAttrsList
        ];

        base = {
          networking.hostName = host.name; # see see config.system.name
          imports = auto_imports;
          system.stateVersion = "25.05";
          users.users = mk_user_sets (_: {
            isNormalUser = true;
            description = "Max";
            extraGroups = ["networkmanager" "wheel"];
          });
          nix.settings.trusted-users = builtins.attrNames (mk_user_sets (_: null));
        };

        hmModule = {
          # Home Manager user config
          home-manager.users = mk_user_sets (_: {
            imports = auto_imports;
            home.stateVersion = "25.05";
          });

          home-manager = {
            useGlobalPkgs = true; # Also inherits nixpkgs configs
            verbose = true;
            extraSpecialArgs = build_special_args host mod_kinds.HOME;
          };
        };
      in
        [base] ++ lib.optionals (!host.hmStandalone) [inputs.home-manager.nixosModules.home-manager hmModule];

      specialArgs = build_special_args host mod_kinds.SYSTEM;
    };

    standalone_hm_config = host: user: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = packagesBySystem.${host.system};
      extraSpecialArgs = build_special_args host mod_kinds.HOME;
      modules = [
        {
          imports = host.modulePaths;
          home.stateVersion = "25.05";
          home.username = user.name;
          home.homeDirectory = host.usersDir user.name;
        }
      ];
    };
  in {
    nixosConfigurations = lib.pipe hosts [
      (builtins.filter (host: host.nixOS))
      (map (host: {
        ${host.name} = nixos_system host;
      }))
      lib.attrsets.mergeAttrsList
    ];

    homeConfigurations = lib.pipe [hosts users] [
      (cross_lists (host: user: {
        "${user.name}@${host.name}" = standalone_hm_config host user;
      }))
      lib.attrsets.mergeAttrsList
    ];

    # This allows using the nix config location like nixpkgs
    # in commands like `nix shell nixpkgs#package`.
    # The packages have the overlays applied to them.
    #
    # Example: `nix profile install /etc/nixos#mathematica`
    # installs the mathematica overlay from the config
    packages = packagesBySystem;
  };
}
