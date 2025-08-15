{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.nixpkgs.lib;

    build-G = name: let
      check = p: ex: got: lib.asserts.assertMsg (p got) "${name}: Expected ${ex}, got: ${got}";
      check-not = p: check (got: !(p got));
      check-bool = check builtins.isBool "bool";

      build-args = host-config @ {
        isLaptop,
        isNixOS,
        localConfigRoot,
      }:
        assert check builtins.isString "string" localConfigRoot;
        assert check-not (lib.strings.hasSuffix "/") "Path without trailing slash" localConfigRoot;
        assert check-bool isLaptop;
        assert check-bool isNixOS; {
          inherit inputs;

          host = host-config // {inherit name;};

          findAutoImports = suffix:
            lib.pipe [./software ./hosts/${name}] [
              (builtins.concatMap lib.filesystem.listFilesRecursive)
              (map toString)
              (builtins.filter (lib.strings.hasSuffix suffix))
            ];
        };
    in
      build-args (import ./hosts/${name}/host-meta.nix inputs);

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
      (map build-G)
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
