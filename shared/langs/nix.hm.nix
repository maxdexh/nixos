{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:
# https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
# FIXME: Throw this into an overlay
# TODO: Precompile into a github release
let alejandra_fork = pkgs.rustPlatform.buildRustPackage rec {
  pname = "alejandra";
  version = "4.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "maxdexh";
    repo = "alejandra";
    rev = version;
    hash = "sha256-Oi1n2ncF4/AWeY6X55o2FddIRICokbciqFYK64XorYk=";
  };

  cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";

  meta = {
    license = lib.licenses.unlicense;
    mainProgram = "alejandra";
  };
}; 
  

in
{
  home.packages = with pkgs; [
    alejandra_fork

    nix-search-cli

    nixfmt-rfc-style
    nixd

    nh
    nix-tree
    pkgs-unstable.dix # unavailable in nixpkgs
    statix
    (config.lib.custom.writeFishApplication {
      name = "nixos-rebuild-diff";
      runtimeInputs = [pkgs-unstable.dix];
      text =
        # fish
        ''
          set -l tmpdir "$(mktemp -d)"
          cd $tmpdir
          nixos-rebuild build $argv
          dix /run/current-system ./result
          rm $tmpdir/result
          rmdir $tmpdir
        '';
    })

    # TODO:
    # https://github.com/thiagokokada/nix-alien
    # https://github.com/nix-community/nix-index
    # https://github.com/nix-community/haumea
    # https://github.com/jpetrucciani/pog
  ];
}
