inputs: let
  mod_kinds = {
    HOME = "hm";
    SYSTEM = "os";
  };

  lib = inputs.nixpkgs.lib;

  hosts = lib.mapAttrsToList (
    name: {
      moduleDirs ? [./hosts/${name}],
      noNixOS ? false,
      system ? "x86_64-linux",
      isHmStandalone ? noNixOS,
    }: {
      inherit system isHmStandalone name;
      moduleDirs = moduleDirs ++ [./shared];
      isNixOS = !noNixOS;
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
      name = mod_kind;
      pick = attrs @ {
        hm ? null,
        os ? null,
      }:
        attrs.${mod_kind};

      os.mod = lib.attrsets.optionalAttrs (mod_kind == mod_kinds.SYSTEM);
      hm.mod = lib.attrsets.optionalAttrs (mod_kind == mod_kinds.HOME);
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

  mixed_extra = {lib.file = {inherit configPathToRel;};};
  crossLists = f: lib.foldl (fs: args: builtins.concatMap (f: map f args) fs) [f];
  host_auto_imports = host: kind: builtins.concatLists (crossLists find_auto_imports [host.moduleDirs [kind "mixed"]]) ++ [mixed_extra];

  nixos-system = host: {
    system = host.system;

    modules = [
      {networking.hostName = host.name;}
      # Configuration for nixpkgs, such as overlays. Only import from system since useGlobalPkgs = true
      ./nixpkgs-conf
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
in {
  nixosConfigurations = lib.pipe hosts [
    (builtins.filter (host: host.isNixOS))
    (map (host: {
      ${host.name} = lib.nixosSystem (nixos-system host);
    }))
    lib.attrsets.mergeAttrsList
  ];
}
