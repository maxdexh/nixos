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

    build-global = host-name: let
      check = p: ex: got: lib.asserts.assertMsg (p got) "${host-name}: Expected ${ex}, got: ${got}";
      check-not = p: check (got: !(p got));
      check-bool = check builtins.isBool "bool";

      build-args = {
        isLaptop,
        isNixOS,
        localConfigRoot,
      }:
        assert check builtins.isString "string" localConfigRoot;
        assert check-not (lib.strings.hasSuffix "/") "Path without trailing slash" localConfigRoot;
        assert check-bool isLaptop;
        assert check-bool isNixOS; {
          inherit inputs;

          host = {
            inherit isLaptop isNixOS;
            name = host-name;
          };

          inherit localConfigRoot;

          findAutoImports = suffix:
            lib.pipe [./software ./hosts/${host-name}] [
              (builtins.concatMap lib.filesystem.listFilesRecursive)
              (map toString)
              (builtins.filter (lib.strings.hasSuffix suffix))
            ];
        };
    in
      build-args (import ./hosts/${host-name}/host-meta.nix inputs);

    host-system = G:
      lib.nixosSystem {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ./system-main.nix
          {networking.hostName = G.host.name;}
        ];

        specialArgs.G = G;
      };
    hosts = lib.pipe (builtins.readDir ./hosts) [
      builtins.attrNames
      (map build-global)
    ];
  in {
    nixosConfigurations = lib.pipe hosts [
      (builtins.filter (G: G.host.isNixOS))
      (map (G: {
        ${G.host.name} = host-system G;
      }))
      lib.attrsets.mergeAttrsList
    ];
  };
}
