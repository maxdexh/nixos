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
      max = {
        trusted = true;
      };
    };

    hosts = lib.mapAttrsToList (name: {
      modulePaths ? [./hosts/${name}],
      system ? "x86_64-linux",
      nixOS ? false,
      # TODO: Remove
      hmStandalone ? false,
      usersDir ? (user: "/home/${name.name}"),
    }: {
      inherit system name nixOS hmStandalone usersDir;
      termux = false; # FIXME: Replace with cliOnly option
      modulePaths = assert hmStandalone || nixOS; modulePaths ++ [./shared];
    }) _hosts;

    users = lib.mapAttrsToList (name: {
      trusted ? false,
      modulePaths ? [],
    }: {
      inherit name trusted;
      modulePaths = modulePaths ++ [./shared];
    }) _users;

    overlays = import ./overlays;
    # Like nixpkgs.legacyPackages, maps systems to packages
    packagesBySystem = lib.pipe hosts [
      (builtins.groupBy (host: host.system))
      (builtins.mapAttrs (system: _: import inputs.nixpkgs {
        inherit system overlays;
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

    build_special_args = host: kind: let
      _mk_ctx = name: {
        ${name} = rec {
          inherit name;
          enabled = kind == name;
          set = lib.optionalAttrs enabled;
          list = lib.optionals enabled;
        };
      };
    in {
      inherit host inputs;
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
      ctx =
        {inherit kind;}
        // _mk_ctx mod_kinds.SYSTEM
        // _mk_ctx mod_kinds.HOME;
    };

    nixos_system = host: let
      auto_imports = host.modulePaths;
    in lib.nixosSystem {
      pkgs = packagesBySystem.${host.system};

      modules = let
        # FIXME: WTF
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
          home.homeDirectory = host.usersDir user;
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
