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

  
  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, ... }: let
    lib = nixpkgs.lib;

    host-system = host-name: let
      host-err = exp: got: "${host-name}: Expected ${exp}, got: ${got}";
      build-args = { isLaptop, localConfigRoot }:
        assert lib.asserts.assertMsg (builtins.isString localConfigRoot)
          (host-err "string" localConfigRoot);
        assert lib.asserts.assertMsg (!lib.strings.hasSuffix "/" localConfigRoot)
          (host-err "Path without trailing slash" localConfigRoot);
        assert lib.asserts.assertMsg (builtins.isBool isLaptop)
          (host-err "bool" isLaptop);
        {
          inherit inputs;

          host = {
            inherit isLaptop;
            name = host-name;
          };

          inherit localConfigRoot;

          findAutoImports = suffix: lib.pipe [ ./software ./hosts/${host-name} ] [
            (builtins.concatMap lib.filesystem.listFilesRecursive)
            (map toString)
            (builtins.filter (lib.strings.hasSuffix suffix))
          ];
        };

      specialArgs.g = build-args (import ./hosts/${host-name}/host-meta.nix inputs);

      in nixpkgs.lib.nixosSystem {
        modules = [
          home-manager.nixosModules.home-manager
          ./system-main.nix
          { networking.hostName = host-name; }
        ];

        inherit specialArgs;
      };
      
      yup =
        map (host-name: { ${host-name} = host-system host-name; }) 
        (builtins.attrNames (builtins.readDir ./hosts));
      configs = builtins.foldl' 
        (a: b: a // b)
        {}
        yup;

  in { nixosConfigurations = configs; };
}
