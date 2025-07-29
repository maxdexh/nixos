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

  outputs = inputs@{ nixpkgs, nixos-hardware, home-manager, ... }: {
    nixosConfigurations = let
      sys-meta = ({ config, pkgs, lib, ... }:
        let all-files = map toString (lib.filesystem.listFilesRecursive ./.);
        in {
          imports =
            builtins.filter (lib.strings.hasSuffix "/system.nix") all-files;

          system.stateVersion = "25.05";

          programs.nix-ld.enable = true;

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          users.users.max = {
            isNormalUser = true;
            description = "Max";
            extraGroups = [ "networkmanager" "wheel" ];
          };

          home-manager.useGlobalPkgs = true;
          home-manager.verbose = true;

          # Home Manager user config
          home-manager.users.max = { lib, pkgs, ... }: {
            imports =
              builtins.filter (lib.strings.hasSuffix "/home.nix") all-files;

            xdg.enable = true;

            home.stateVersion = "25.05";
          };
        });
      host-names = builtins.attrNames (builtins.readDir ./hosts);
      make-host-entry = host-name: {
        name = host-name;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.home-manager
            sys-meta
            { networking.hostName = host-name; }
            ./hosts/${host-name}/host.nix
          ];
        };
      };
      configs = builtins.listToAttrs (map make-host-entry host-names);
    in configs;
  };
}
