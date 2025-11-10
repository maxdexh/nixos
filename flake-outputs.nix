inputs: let
  overlays = final: prev: {
    # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
    # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
    alejandra = prev.rustPlatform.buildRustPackage {
      pname = "alejandra";
      version = "4.0.0";

      # FIXME: Precompile into github release
      src = builtins.fetchGit {
        url = "https://github.com/maxdexh/alejandra";
        rev = "a5ca19c749397302cba8245b0229d4efebfd3c35";
      };

      # FIXME: Remove after adjusting tests
      doCheck = false;

      cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";

      meta = {
        license = prev.lib.licenses.unlicense;
        mainProgram = "alejandra";
      };
    };
  };

  mod_kinds = {
    HOME = "hm";
    SYSTEM = "os";
  };

  lib = inputs.nixpkgs.lib;

  hosts = lib.mapAttrsToList (name: {
    moduleDirs ? [./hosts/${name}],
    system ? "x86_64-linux",
    termux ? false,
    nixOS ? false,
    # TODO: Add back host option for standalone home-manager
  }: {
    inherit system name nixOS termux;
    moduleDirs = assert termux || nixOS; moduleDirs ++ [./shared];
  }) (import ./hosts.nix);

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
      os.set = lib.attrsets.optionalAttrs (mod_kind == mod_kinds.SYSTEM);
      hm.set = lib.attrsets.optionalAttrs (mod_kind == mod_kinds.HOME);
    };
  };

  findAutoImports = basepath: kind: lib.pipe basepath [
    lib.filesystem.listFilesRecursive
    (map toString)
    (builtins.filter (path: lib.hasSuffix ".${kind}.nix" path || lib.hasSuffix "/${kind}.nix" path))
    (imports: builtins.trace "Importing ${toString (builtins.length imports)} ${kind} files from ${configPathToRel basepath}" imports)
  ];

  crossLists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f]; # Copy of the deprecated lib.crossLists
  findHostAutoImports = host: kind: builtins.concatLists (crossLists findAutoImports [host.moduleDirs [kind "mixed"]]);

  nixosSystem = host: {
    system = assert host.nixOS; host.system;

    modules = [
      # Also sets the default name of the flake that is selected by nixos-rebuild, i.e.
      # `--flake .#name` only needs to be used once
      {networking.hostName = host.name;}
      # System base
      {
        imports = findHostAutoImports host mod_kinds.SYSTEM;
        system.stateVersion = "25.05";
        nixpkgs.overlays = [overlays];
      }
      # Users
      {
        users.users.max = {
          isNormalUser = true;
          description = "Max";
          extraGroups = ["networkmanager" "wheel"];
        };
        nix.settings.trusted-users = ["max"];
      }

      # home-manager as a nixos module
      inputs.home-manager.nixosModules.home-manager
      {
        # Home Manager user config
        home-manager.users.max = {
          imports = findHostAutoImports host mod_kinds.HOME;
          home.stateVersion = "25.05";
        };

        home-manager = {
          useGlobalPkgs = true; # Also inherits overlays
          verbose = true;
          extraSpecialArgs = build_special_args host mod_kinds.HOME;
        };
      }
    ];

    specialArgs = build_special_args host mod_kinds.SYSTEM;
  };

  buildConfig = filter: mkSystem: systemSpec: lib.pipe hosts [
    (builtins.filter filter)
    (map (host: {${host.name} = mkSystem (systemSpec host);}))
    lib.attrsets.mergeAttrsList
  ];
in {
  nixosConfigurations = buildConfig (host: host.nixOS) lib.nixosSystem nixosSystem;

  nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
    modules = [./nix-on-droid.nix];
  };
}
