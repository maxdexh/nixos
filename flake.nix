{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;

    build-G = name: {
      inherit inputs;

      findAutoImports = suffix:
        lib.pipe [./software ./hosts/${name}] [
          (builtins.concatMap lib.filesystem.listFilesRecursive)
          (map toString)
          (builtins.filter (lib.strings.hasSuffix suffix))
        ];

      host = let
        check = p: ex: got: lib.asserts.assertMsg (p got) "${name}: Expected ${ex}, got: ${got}";
        check-not = p: check (got: !(p got));
        check-bool = check builtins.isBool "bool";

        check-host = host-config @ {
          isLaptop,
          isNixOS,
          localConfigRoot,
        }:
          assert check builtins.isString "string" localConfigRoot;
          assert check-not (lib.strings.hasSuffix "/") "Path without trailing slash" localConfigRoot;
          assert check-bool isLaptop;
          assert check-bool isNixOS;
            host-config // {inherit name;};
      in
        check-host (import ./hosts/${name}/host-meta.nix inputs);
    };

    hosts = lib.pipe (builtins.readDir ./hosts) [
      builtins.attrNames
      (map build-G)
    ];
  in {
    nixosConfigurations = lib.pipe hosts [
      (builtins.filter (G: G.host.isNixOS))
      (map (G: {
        ${G.host.name} = lib.nixosSystem {
          modules = [
            inputs.home-manager.nixosModules.home-manager
            ./system-main.nix
            ./global-overlays.nix
            {networking.hostName = G.host.name;}
          ];

          specialArgs.G = G;
        };
      }))
      lib.attrsets.mergeAttrsList
    ];
  };
}
