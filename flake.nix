{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nix profile install nixpkgs/nixpkgs-unstable#packagename
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;

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
        builtins.trace "Found ${toString (builtins.length imports)} auto-imports of kind '${kind}' in ./${relpath}" imports;

      mixed = filter-kind "mixed";
    in
      kind: mixed ++ (filter-kind kind);

    find-host-imports = let
      find-host-agnostic = find-imports-in "shared";
    in
      host: let
        find-host-specific = find-imports-in "hosts/${host}";
      in
        kind: builtins.concatMap (find: find kind) [find-host-specific find-host-agnostic];

    build-G = host-name: rec {
      inherit inputs;

      host = let
        check-msg = cond: msg: lib.asserts.assertMsg cond "${host-name}: ${msg}";
        expect = p: ex: got: check-msg (p got) "Expected ${ex}, got: ${got}";
        expect-bool = expect builtins.isBool "bool";
        check-host = host-config @ {
          isLaptop,
          isNixOS,
          system,
          nixosConfigLocation ? "",
        }:
          assert expect-bool isLaptop;
          assert expect-bool isNixOS;
          assert expect (it: inputs.nixpkgs.legacyPackages ? ${it}) "Nixpkgs system" system;
          assert expect builtins.isString "string" nixosConfigLocation;
            host-config
            // {
              name = host-name;
              nixosConfigLocation = lib.removeSuffix "/" nixosConfigLocation;
            };
      in
        check-host (import ./hosts/${host-name}/host-meta.nix inputs);

      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
    };

    host-Gs = lib.pipe (builtins.readDir ./hosts) [
      builtins.attrNames
      (map build-G)
    ];

    nixos-system = G: let
      find-imports = find-host-imports G.host.name;
    in {
      system = G.host.system;

      modules = [
        {networking.hostName = G.host.name;}
        # Configuration for nixpkgs, such as overlays. Only import from system because useGlobalPkgs = true
        ./nixpkgs-conf
        # System base
        {
          imports = find-imports "system";
          system.stateVersion = "25.05";
        }
        # Users
        inputs.home-manager.nixosModules.home-manager
        {
          users.users.max = {
            isNormalUser = true;
            description = "Max";
            extraGroups = ["networkmanager" "wheel"];
          };

          # Home Manager user config
          home-manager.users.max = {
            imports = find-imports "home";
            home.stateVersion = "25.05";
          };

          home-manager = {
            useGlobalPkgs = true;
            verbose = true;
            extraSpecialArgs.G = G // {kind = "home";};
          };
        }
      ];

      specialArgs.G = G // {kind = "system";};
    };
  in {
    nixosConfigurations = lib.pipe host-Gs [
      (builtins.filter (G: G.host.isNixOS))
      (map (G: {
        ${G.host.name} = lib.nixosSystem (nixos-system G);
      }))
      lib.attrsets.mergeAttrsList
    ];
  };
}
