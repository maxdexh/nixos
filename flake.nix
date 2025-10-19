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
          localConfigRoot ? "",
        }:
          assert expect-bool isLaptop;
          assert expect-bool isNixOS;
          assert expect (it: inputs.nixpkgs.legacyPackages ? ${it}) "Nixpkgs system" system;
          assert expect builtins.isString "string" localConfigRoot;
            host-config
            // {
              inherit name;
              localConfigRoot = lib.removeSuffix "/" localConfigRoot;
            };
      in
        check-host (import ./hosts/${name}/host-meta.nix inputs);

      findAutoImports = suffix:
        lib.pipe [./common ./hosts/${name}] [
          (builtins.concatMap lib.filesystem.listFilesRecursive)
          (map toString)
          (builtins.filter (path: lib.strings.hasSuffix ".${suffix}" path || lib.strings.hasSuffix "/${suffix}" path))
          (files: builtins.trace "Found ${toString (builtins.length files)} imports for '${suffix}'" files)
        ];

      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${host.system};
    };

    hosts = lib.pipe (builtins.readDir ./hosts) [
      builtins.attrNames
      (map build-G)
    ];

    nixos-system = G: {
      system = G.host.system;

      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./system-main.nix
        ./global-overlays.nix
        {networking.hostName = G.host.name;}
      ];

      specialArgs.G = G;
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
