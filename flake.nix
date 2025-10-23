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

    build-G = name: rec {
      inherit inputs;

      host = let
        check-msg = cond: msg: lib.asserts.assertMsg cond "${name}: ${msg}";
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
              inherit name;
              nixosConfigLocation = lib.removeSuffix "/" nixosConfigLocation;
            };
      in
        check-host (import ./hosts/${name}/host-meta.nix inputs);

      findAutoImports = let
        import-candidates = lib.pipe [./shared ./hosts/${name}] [
          (builtins.concatMap lib.filesystem.listFilesRecursive)
          (map toString)
        ];
        auto-imports-of-kind = kind: let
          it = builtins.filter (path: lib.strings.hasSuffix ".${kind}.nix" path || lib.strings.hasSuffix "/${kind}.nix" path) import-candidates;
        in
          builtins.trace "Found ${toString (builtins.length it)} auto-imports of kind '${kind}'" it;

        auto-imports-mixed = auto-imports-of-kind "mixed";
      in
        kind: assert kind != "mixed"; (auto-imports-of-kind kind) ++ auto-imports-mixed;

      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
    };

    hosts = lib.pipe (builtins.readDir ./hosts) [
      builtins.attrNames
      (map build-G)
    ];

    nixos-system = G: {
      system = G.host.system;

      modules = [
        {networking.hostName = G.host.name;}
        # Configuration for nixpkgs, such as overlays. Only import from system because useGlobalPkgs = true
        ./nixpkgs-conf
        # System base
        {
          imports = G.findAutoImports "system";
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
            imports = G.findAutoImports "home";
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
    nixosConfigurations = lib.pipe hosts [
      (builtins.filter (G: G.host.isNixOS))
      (map (G: {
        ${G.host.name} = lib.nixosSystem (nixos-system G);
      }))
      lib.attrsets.mergeAttrsList
    ];
  };
}
