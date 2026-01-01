{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # nix profile install nixpkgs/nixpkgs-unstable#packagename
    # TODO: Also add overlays to this and make them available
    # like the overlayed nixpks
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra-fork = {
      url = "github:maxdexh/alejandra";
      flake = false;
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;

    # TODO: Try to add nixd completions for this somehow?
    module_system = lib.evalModules {
      modules = [
        ./hosts
        ./options
        ./modules
        ./overlays
      ];
      specialArgs = {
        inherit inputs;
      };
    };
    full_config = module_system.config;

    # Some attributes for host._internals that are only available in this flake
    # (specialArgs gets the original host attrset)
    host_flake_internals = host: let
      pkgs = pkgs_by_system.${host.system};

      path_prefix = "${inputs.self}/";
      mkNixConfigSymlink = path: let
        # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
        # Could also be done without the builtin by traversing backwards using
        # `+ "/.."` and using `baseNameOf` to get each path segment.
        abs = builtins.unsafeDiscardStringContext (toString path);
        rel = assert lib.hasPrefix path_prefix abs; lib.removePrefix path_prefix abs;
      in "${nixConfigSymlink}/${rel}";
      nixConfigSymlink = pkgs.cfgUtils.mkSymlink host.nixConfigLocation;
    in {
      inherit pkgs;
      specialArgs = {
        inherit inputs;

        unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
        host = host // {inherit nixConfigSymlink mkNixConfigSymlink;};
      };
    };
    hosts = map (host: host // {_internals = host_flake_internals host;}) (builtins.attrValues full_config.hosts);

    pkgs_by_system = lib.pipe hosts [
      (builtins.groupBy (host: host.system))
      (builtins.mapAttrs (system: _: import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues full_config.overlays;
        config = {
          allowUnfree = true;
        };
      }))
    ];

    nixos_system = host: lib.nixosSystem {
      pkgs = host._internals.pkgs;

      modules = [
        host.nixos.module
        {
          home-manager = {
            useGlobalPkgs = true; # Also inherits nixpkgs configs
            verbose = true;
            extraSpecialArgs = host._internals.specialArgs;
          };
        }
        inputs.home-manager.nixosModules.home-manager
      ];

      specialArgs = host._internals.specialArgs;
    };

    standalone_hm_config = host: user: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs_by_system.${host.system};
      extraSpecialArgs = host._internals.specialArgs;
      modules = [user.hm.module];
    };
  in {
    nixosConfigurations = lib.pipe hosts [
      (builtins.filter (host: host.nixos.enable))
      (map (host: {
        name = host.name;
        value = nixos_system host;
      }))
      builtins.listToAttrs
    ];

    homeConfigurations = lib.pipe hosts [
      (builtins.concatMap (host: map (user: {
        name = "${user.username}@${host.name}";
        value = standalone_hm_config host user;
      }) (builtins.attrValues host.users)))
      builtins.listToAttrs
    ];

    # This allows using the nix config location as a replacement for nixpkgs,
    # but with overlays applied.
    # Also see ./modules/base.nix
    packages = pkgs_by_system;
  };
}
