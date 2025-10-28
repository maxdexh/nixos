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
      nixOS ? false,
      standaloneHm ? false,
    }: {
      inherit system name nixOS standaloneHm;
      moduleDirs = assert standaloneHm || nixOS; moduleDirs ++ [./shared];
    }
  ) (import ./hosts.nix);

  configPathToRel = lib.flip lib.pipe [
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
      (builtins.filter (lib.strings.hasSuffix "${kind}.nix"))
      (builtins.filter (path: lib.strings.hasSuffix ".${kind}.nix" path || lib.strings.hasSuffix "/${kind}.nix" path))
      (imports: builtins.trace "Auto-importing ${toString (builtins.length imports)} of kind '${kind}' in ${configPathToRel basepath}" imports)
    ];

  crossLists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f];
  host_auto_imports = host: kind: builtins.concatLists (crossLists find_auto_imports [host.moduleDirs [kind "mixed"]]);

  nixos-system = host: {
    system = assert host.nixOS; host.system;

    modules =
      [
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
      ]
      ++ lib.optionals host.standaloneHm [
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

  hm-system = host: {
    pkgs = assert host.standaloneHm; inputs.nixpkgs.legacyPackages.${host.system};
    modules = [
      {
        imports = host_auto_imports host mod_kinds.HOME;
        home.stateVersion = "25.05";
      }
    ];
    specialArgs = build_special_args host mod_kinds.HOME;
  };

  build-configs = filter: mkSystem: systemSpec:
    lib.pipe hosts [
      (builtins.filter (host: host.${filter}))
      (map (host: {${host.name} = mkSystem (systemSpec host);}))
      lib.attrsets.mergeAttrsList
    ];
in {
  nixosConfigurations = build-configs "nixOS" lib.nixosSystem nixos-system;
  homeConfigurations = build-configs "standaloneHm" inputs.home-manager.lib.homeManagerConfiguration hm-system;
}
