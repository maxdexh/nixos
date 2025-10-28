{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: {
  home.packages = with pkgs; [
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
