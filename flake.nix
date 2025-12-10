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

    module_system = lib.evalModules {
      modules = [
        ./hosts
        ./options
      ];
      specialArgs = {
        inherit inputs;
      };
    };
    full_config = module_system.config;

    cond_module = cond: module: args: lib.mkIf cond (lib.toFunction module args);

    modules_of = host: let
      tags = full_config.defaultTags // host.tags;
      parts =
        map
        (part: let
          cond = cond_module (builtins.any (tag: tags.${tag}) part.tags);
        in {
          hm = cond part.hm;
          nixos = cond part.nixos;
        })
        (builtins.attrValues full_config.parts);
      modules = lib.zipAttrs parts;
    in {
      nixos = modules.nixos or [];
      hm = modules.hm or [];
    };
    hosts = map (host: host // {modules = modules_of host;}) (builtins.attrValues full_config.hosts);

    alejandra_overlay = final: prev: {
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
    };

    # TODO: Use another module system for overlays, and let them depend on hosts
    # (how to make outputs.packages depend on host?)
    overlays = import ./overlays ++ [alejandra_overlay];
    # Like nixpkgs.legacyPackages, maps systems to packages
    pkgs_by_system = lib.pipe hosts [
      (builtins.groupBy (host: host.system))
      (builtins.mapAttrs (system: _: import inputs.nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
        };
      }))
    ];

    mk_special_args = host: kind: let
      pkgs = pkgs_by_system.${host.system};
      mkSymlink = path: let path_str = toString path; in pkgs.runCommandLocal path_str {} "ln -s ${lib.escapeShellArg path_str} $out";
      nixConfigSymlink = mkSymlink host.nixConfigLocation;
      path_prefix = "${inputs.self}/";
      mkNixConfigSymlink = path: let
        # Turn /nix/store/<hash>-<basename> into ${source-store}/actual/path/to/<basename>
        # Could also be done without the builtin by traversing backwards using
        # `+ "/.."` and using `baseNameOf` to get each path segment.
        abs = builtins.unsafeDiscardStringContext (toString path);
        rel = assert lib.hasPrefix path_prefix abs; lib.removePrefix path_prefix abs;
      in "${nixConfigSymlink}/${rel}";
    in {
      inherit inputs mkSymlink;
      unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
      host = host // {inherit nixConfigSymlink mkNixConfigSymlink;};
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
        // mk "os"
        // mk "hm";
    };

    base_hm_module = host: user: {
      imports = [host.hm.sharedModule user.hm.module ./modules] ++ host.modules.hm;
      home.stateVersion = "25.05";
    };

    nixos_system = host: lib.nixosSystem {
      pkgs = pkgs_by_system.${host.system};

      modules = [
        {
          networking.hostName = host.name; # see config.system.name
          imports = [host.nixos.module ./modules] ++ host.modules.nixos;
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
            builtins.mapAttrs (_: user: base_hm_module host user)
            host.users;

          home-manager = {
            useGlobalPkgs = true; # Also inherits nixpkgs configs
            verbose = true;
            extraSpecialArgs = mk_special_args host "hm";
          };
        }
        inputs.home-manager.nixosModules.home-manager
      ];

      specialArgs = mk_special_args host "os";
    };

    standalone_hm_config = host: user: inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs_by_system.${host.system};
      extraSpecialArgs = mk_special_args host "hm";
      modules = [
        (base_hm_module host user)
        {
          home.username = user.name;
          home.homeDirectory = user.homeDirectory;
        }
      ];
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
        name = "${user.name}@${host.name}";
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
