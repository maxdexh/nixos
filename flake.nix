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

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, ... }: {
    nixosConfigurations = let
      all-files = map toString (nixpkgs.lib.filesystem.listFilesRecursive ./.);

      host-names = builtins.attrNames (builtins.readDir ./hosts);

      make-host-entry = host-name:
        let
          host-config = ./hosts/${host-name}/host.nix;

          type-err = expexted: value:
            throw "${host-name}: Expected type ${expexted}, got ${
              builtins.typeOf value
            }: ${value}";

          check-host-meta = { isLaptop, localConfigRoot }:
            if !builtins.isString localConfigRoot then
              type-err "string" localConfigRoot
            else if !builtins.isBool isLaptop then
              type-err "bool" isLaptop
            else {
              host = {
                inherit isLaptop;
                name = host-name;
              };

              inherit localConfigRoot;
            };

          specialArgs = {
            inherit inputs;
            config-meta = check-host-meta
              (import ./hosts/${host-name}/host-meta.nix inputs);
          };

          sys-main = ({ config, pkgs, lib, ... }: {
            imports =
              (builtins.filter (lib.strings.hasSuffix "/system.nix") all-files);

            system.stateVersion = "25.05";

            programs.nix-ld.enable = true;

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            users.users.max = {
              isNormalUser = true;
              description = "Max";
              extraGroups = [ "networkmanager" "wheel" ];
            };

            # Home Manager user config
            home-manager.users.max = { inputs, lib, pkgs, ... }: {
              imports =
                builtins.filter (lib.strings.hasSuffix "/home.nix") all-files;

              xdg.enable = true;

              home.stateVersion = "25.05";
            };

            home-manager = {
              useGlobalPkgs = true;
              verbose = true;
              extraSpecialArgs = specialArgs;
            };
          });

        in {
          name = host-name;

          value = nixpkgs.lib.nixosSystem {
            modules = [
              home-manager.nixosModules.home-manager
              sys-main
              { networking.hostName = host-name; }
              host-config
            ];

            inherit specialArgs;
          };
        };

      configs = builtins.listToAttrs (map make-host-entry host-names);

    in configs;
  };
}
