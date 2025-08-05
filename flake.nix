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
      find-auto-imports = suffix: basedirs:
        nixpkgs.lib.pipe basedirs [
          (builtins.concatMap nixpkgs.lib.filesystem.listFilesRecursive)
          (map toString)
          (builtins.filter (nixpkgs.lib.strings.hasSuffix suffix))
        ];

      find-home-auto-imports = find-auto-imports "/home.nix";
      find-sys-auto-imports = find-auto-imports "/system.nix";

      host-names = builtins.attrNames (builtins.readDir ./hosts);

      make-host-entry = host-name:
        let
          auto-import-paths = [ ./software ./hosts/${host-name} ];

          type-err = expexted: value:
            throw "${host-name}: Expected ${expexted}, got: ${value}";

          check-host-meta = { isLaptop, localConfigRoot }:
            if !builtins.isString localConfigRoot
            || nixpkgs.lib.strings.hasSuffix "/" localConfigRoot then
              type-err "String without trailing slash" localConfigRoot
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
            imports = find-sys-auto-imports auto-import-paths;

            system.stateVersion = "25.05";

            programs.nix-ld.enable = true;

            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nix.gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 14d";
            };
            nix.optimise.automatic = true;

            users.users.max = {
              isNormalUser = true;
              description = "Max";
              extraGroups = [ "networkmanager" "wheel" ];
            };

            # Home Manager user config
            home-manager.users.max = { inputs, lib, pkgs, ... }: {
              imports = find-home-auto-imports auto-import-paths;

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
            ];

            inherit specialArgs;
          };
        };

      configs = builtins.listToAttrs (map make-host-entry host-names);

    in configs;
  };
}
