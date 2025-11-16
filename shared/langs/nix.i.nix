{
  pkgs,
  pkgs-unstable,
  config,
  lib,
  host,
  ctx,
  ...
}: ctx.hm.set {
  home.packages = with pkgs; [
    alejandra

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
      text = /* fish */ ''
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

  custom.sessionVars = {
    NH_FLAKE = config.custom.host.nixConfigLocation;
  };

  programs.fish.shellAbbrs = lib.mkMerge [
    {
      hm = "home-manager";
      # hmr = "home-manager repl"; # FIXME: get nh home repl to work or write one yourself
      hms = "home-manager switch";
    }
    (lib.mkIf host.nixOS {
      os = "nixos-rebuild";
      osr = "nixos-rebuild repl";
      oss = "sudo nixos-rebuild switch";
      osd = "nixos-rebuild-diff"; # TODO: Write one for hm too
    })
  ];
}
