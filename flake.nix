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
    alejandra-fork = {
      url = "github:maxdexh/alejandra";
      flake = false;
    };
  };

  outputs = inputs: let
    hosts = import ./hosts inputs;
    alejandra_overlay = (
      final: prev: {
        # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
        # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
        # FIXME: Provide a better flake.nix over there instead.
        alejandra = prev.rustPlatform.buildRustPackage {
          pname = "alejandra";
          version = "4.0.0";
          src = inputs.alejandra-fork;
          doCheck = false;
          cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";
          meta = {
            license = prev.lib.licenses.unlicense;
            mainProgram = "alejandra";
          };
        };
      }
    );
    overlays = import ./overlays ++ [alejandra_overlay];
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

    build_special_args = host: kind: {
      inherit host inputs;
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
      ctx = let
        mk = name: {
          ${name} = rec {
            inherit name;
            enabled = kind == name;
            set = lib.optionalAttrs enabled;
            list = lib.optionals enabled;
          };
        };
      in
        {inherit kind;}
        // mk mod_kinds.SYSTEM
        // mk mod_kinds.HOME;
    };

    nixos_system = host: lib.nixosSystem {
      pkgs = packagesBySystem.${host.system};

      modules = [
        {
          networking.hostName = host.name; # see config.system.name
          imports = host.modulePaths;
          system.stateVersion = "25.05";
          users.users =
            builtins.mapAttrs (_: user: {
              isNormalUser = true;
              description = user.name;
              extraGroups = ["networkmanager" "wheel"];
            })
            host.users;
          nix.settings.trusted-users = builtins.attrNames host.users;
        }
        {
          # Home Manager user config
          home-manager.users =
            builtins.mapAttrs (_: user: {
              imports = user.modulePaths;
              home.stateVersion = "25.05";
            })
            host.users;

          home-manager = {
            useGlobalPkgs = true; # Also inherits nixpkgs configs
            verbose = true;
            extraSpecialArgs = build_special_args host mod_kinds.HOME;
          };
        }
        inputs.home-manager.nixosModules.home-manager
      ];

      specialArgs = build_special_args host mod_kinds.SYSTEM;
    };

    standalone_hm_config = user: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = packagesBySystem.${user.host.system};
      extraSpecialArgs = build_special_args user.host mod_kinds.HOME;
      modules = [
        {
          imports = user.modulePaths;
          home.stateVersion = "25.05";
          home.username = user.name;
          home.homeDirectory = user.homeDirectory;
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

    homeConfigurations = lib.pipe hosts [
      (builtins.concatMap (host: builtins.attrValues host.users))
      (map (
        user: {
          name = user.homeConfigurationName;
          value = standalone_hm_config user;
        }
      ))
      builtins.listToAttrs
    ];

    # This allows using the nix config location as a replacement for nixpkgs,
    # but with overlays applied.
    # Also see ./shared/base.nix
    packages = packagesBySystem;
  };
}
