{
  pkgs,
  pkgs-unstable,
  config,
  custom,
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
    (custom.lib.writeFishApplication {
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
    (pkgs.writeShellScriptBin "nix-cfg-repl" (builtins.readFile ./repl.bash))

    # TODO: nix devenv, use flake-compat for large repos

    # TODO:
    # https://github.com/thiagokokada/nix-alien
    # https://github.com/nix-community/nix-index
    # https://github.com/nix-community/haumea
    # https://github.com/jpetrucciani/pog
  ];

  custom.sessionVars = {
    NIXOS_FLAKE = custom.host.nixConfigLocation;
  };

  programs.fish.shellAbbrs = lib.mkMerge [
    {
      hm = "home-manager";
      hmr = "nix-cfg-repl hm"; # TODO: Merged repl
      hms = "home-manager switch";
      hml = "journalctl -xeu home-manager-max.service";
      # TODO: Write a script for this instead
      hm-option = "nixos-option home-manager.users.${config.home.username}.";
    }
    (lib.mkIf host.nixOS {
      os = "nixos-rebuild";
      osr = "nixos-rebuild repl";
      oss = "sudo nixos-rebuild switch";
      osd = "nixos-rebuild-diff"; # TODO: Write one for hm too
    })
  ];
}
