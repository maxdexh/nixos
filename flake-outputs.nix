inputs: let
  mod_kinds = {
    HOME = "hm";
    SYSTEM = "os";
  };

  lib = inputs.nixpkgs.lib;

  hosts = lib.mapAttrsToList (
    name: {
      moduleDirs ? [./hosts/${name}],
      system ? "x86_64-linux",
      termux ? false,
      nixOS ? false,
    }: {
      inherit system name nixOS termux;
      moduleDirs = assert termux || nixOS; moduleDirs ++ [./shared];
    }
  ) (import ./hosts.nix);

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

  find_auto_imports = basepath: kind:
    lib.pipe basepath [
      lib.filesystem.listFilesRecursive
      (map toString)
      (builtins.filter (path: lib.hasSuffix ".${kind}.nix" path || lib.hasSuffix "/${kind}.nix" path))
      (imports: builtins.trace "Importing ${toString (builtins.length imports)} ${kind} files from ${configPathToRel basepath}" imports)
    ];

  crossLists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f];
  host_auto_imports = host: kind: builtins.concatLists (crossLists find_auto_imports [host.moduleDirs [kind "mixed"]]);

  nixos-system = host: {
    system = assert host.nixOS; host.system;

    modules = [
      {networking.hostName = host.name;}
      # System base
      {
        imports = host_auto_imports host mod_kinds.SYSTEM;
        system.stateVersion = "25.05";
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
      {
        # Home Manager user config
        home-manager.users.max = {
          imports = host_auto_imports host mod_kinds.HOME;
          home.stateVersion = "25.05";
        };

        home-manager = {
          useGlobalPkgs = true;
          verbose = true;
          extraSpecialArgs = build_special_args host mod_kinds.HOME;
        };
      }
      inputs.home-manager.nixosModules.home-manager
    ];

    specialArgs = build_special_args host mod_kinds.SYSTEM;
  };

  build-configs = filter: mkSystem: systemSpec:
    lib.pipe hosts [
      (builtins.filter filter)
      (map (host: {${host.name} = mkSystem (systemSpec host);}))
      lib.attrsets.mergeAttrsList
    ];
in {
  nixosConfigurations = build-configs (host: host.nixOS) lib.nixosSystem nixos-system;

  nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
    modules = [./nix-on-droid.nix];
  };
}
