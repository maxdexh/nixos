{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    nixfmt-rfc-style
    nix-search-cli

    nh
    manix
    nix-diff
    nix-du
    nix-tree
    pkgs-unstable.dix
    statix
    nix-health
    (pkgs.helpers.writeFishApplication {
      name = "nixos-rebuild-diff";
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
    # https://github.com/faukah/dix
    # https://github.com/nix-community/nix-index
    # https://github.com/nix-community/haumea
    # https://github.com/jpetrucciani/pog
  ];
}
