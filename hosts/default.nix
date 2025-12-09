inputs: let
  lib = inputs.nixpkgs.lib;
in (lib.evalModules {
  modules = [
    ./options.nix
    ./default-users.nix
    ./fw13
    ./homepc
  ];
  specialArgs = {
    inherit inputs;
  };
}).config.hosts
