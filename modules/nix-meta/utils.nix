{lib, ...}: {
  parts.nix-utils = {
    enableIf.tags.personal = true;

    hm = {
      pkgs,
      config,
      host,
      ...
    }: let
      programs_sql_cache = "${config.xdg.cacheHome}/nix-programs-sql";
    in {
      programs.nix-init.enable = true;

      programs.command-not-found = {
        enable = true;
        dbPath = "${programs_sql_cache}/programs.sqlite";
      };

      programs.nh = {
        enable = true;
        flake = host.nixConfigLocation;
      };

      home.packages = [
        (pkgs.writeShellScriptBin "fetch-nix-programs" ''
          mkdir -p ${lib.escapeShellArg programs_sql_cache} && cd "$_"
          curl -sL 'https://channels.nixos.org/nixos-25.11-small/nixexprs.tar.xz' | tar -xvJ --wildcards '*/programs.sqlite' --strip-components 1
        '')
        pkgs.alejandra

        pkgs.nix-search-cli
        # TODO: https://github.com/Hovirix/neix/tree/main
        # TODO: Consider writing similar `nix search` wrapper with caching and better output format (more like nix-search-cli)

        pkgs.nh
        pkgs.dix
        (pkgs.cfgUtils.writeFishApplication {
          name = "nixos-rebuild-diff";
          runtimeInputs = [pkgs.dix];
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
        # TODO: Shell completions
        (pkgs.cfgUtils.writeFishApplication {
          name = "nix-shell-run";
          runtimeInputs = [
            (pkgs.cfgUtils.writeFishApplication {
              name = ".nix-shell-safe-run";
              text = /* fish */ ''
                set -l cmd
                for i in (seq 1 "$NIX_SHELL_SAFE_RUN_ARGC")
                  set -l varname "NIX_SHELL_SAFE_RUN_ARG$i"
                  set --append cmd "$$varname"
                end
                exec $cmd
              '';
            })
          ];
          text = /* fish */ ''
            set -x NIX_SHELL_SAFE_RUN_ARGC "$(builtin count $argv)"
            for i in (seq 1 "$NIX_SHELL_SAFE_RUN_ARGC")
              set -x "NIX_SHELL_SAFE_RUN_ARG$i" "$argv[$i]"
            end
            nix-shell --run '.nix-shell-safe-run'
          '';
        })

        # TODO: nix devenv, use flake-compat for large repos

        # TODO:
        # https://github.com/thiagokokada/nix-alien
        # https://github.com/nix-community/nix-index
        # https://github.com/nix-community/haumea
        # https://github.com/jpetrucciani/pog
      ];

      custom.sessionVars = {
        NIXOS_FLAKE = host.nixConfigLocation;
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
        (lib.mkIf host.nixos.enable {
          os = "nixos-rebuild";
          osr = "nixos-rebuild repl";
          oss = "sudo nixos-rebuild switch";
          # TODO: Can we do the same thing but to diff the config by imitating the nixos-option command?
          osd = "nixos-rebuild-diff"; # TODO: Write one for hm too
        })
      ];
    };
  };
}
