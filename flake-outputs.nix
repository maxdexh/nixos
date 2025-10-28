inputs: let
  mod_kinds = {
    HOME = "hm";
    SYSTEM = "os";
  };
  mixed_mod = "mixed";

  lib = inputs.nixpkgs.lib;

  hosts = lib.mapAttrsToList (
    name: {
      modulePath ? "./hosts/${name}",
      noNixOS ? false,
      system ? "x86_64-linux",
      isHmStandalone ? noNixOS,
    }: {
      inherit modulePath system isHmStandalone name;
      isNixOS = !noNixOS;
    }
  ) (import ./hosts/hosts.nix);

  build-special-args = host: mod_kind: {
    inherit host inputs;
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

  find-imports-in = relpath: let
    basepath = ./${relpath};
    candidates = lib.pipe basepath [
      lib.filesystem.listFilesRecursive
      (map toString)
      (builtins.filter (lib.strings.hasSuffix ".nix"))
    ];
    filter-kind = kind: let
      imports = builtins.filter (path: lib.strings.hasSuffix ".${kind}.nix" path || lib.strings.hasSuffix "/${kind}.nix" path) candidates;
    in
      builtins.trace "Auto-importing ${toString (builtins.length imports)} of kind '${kind}' in ${relpath}" imports;

    mixed = filter-kind mixed_mod;
  in
    kind: mixed ++ (filter-kind kind);

  find-host-imports = let
    find-host-agnostic = find-imports-in "./shared";
  in
    host: let
      find-host-specific = find-imports-in host.modulePath;
    in
      kind: builtins.concatMap (find: find kind) [find-host-specific find-host-agnostic];

  nixos-system = host: let
    find-imports = find-host-imports host;
  in {
    system = host.system;

    modules = [
      {networking.hostName = host.name;}
      # Configuration for nixpkgs, such as overlays. Only import from system since useGlobalPkgs = true
      ./nixpkgs-conf
      # System base
      {
        imports = find-imports mod_kinds.SYSTEM;
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
          imports = find-imports mod_kinds.HOME;
          home.stateVersion = "25.05";
        };

        home-manager = {
          useGlobalPkgs = true;
          verbose = true;
          extraSpecialArgs = build-special-args host mod_kinds.HOME;
        };
      }
      inputs.home-manager.nixosModules.home-manager
    ];

    specialArgs = build-special-args host mod_kinds.SYSTEM;
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
