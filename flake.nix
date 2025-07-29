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

  outputs = { nixpkgs, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = system; };

      lib = pkgs.lib;

      all-files = map toString (lib.filesystem.listFilesRecursive ./.);
    in {
      nixosConfigurations = {
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware-configuration.nix

            # nixos-hardware via flake input
            nixos-hardware.nixosModules.framework-13-7040-amd

            # home-manager module
            home-manager.nixosModules.home-manager

            ({ config, pkgs, lib, ... }: {
              system.stateVersion = "25.05";

              programs.nix-ld.enable = true;

              networking.hostName = "framework";

              imports =
                builtins.filter (lib.strings.hasSuffix "/system.nix") all-files;

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
            })
          ];
        };
      };
    };
}
