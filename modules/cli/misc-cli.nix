let
  shellint-no-bash = {
    enable = true;
    enableFishIntegration = true;
  };

  shellint = {enableBashIntegration = true;} // shellint-no-bash;

  ls_aliases = {
    ll = "ls -l";
    la = "ls -a";
    lla = "ls -la";
    lt = "eza --tree";
  };
in {
  parts.misc-cli = {
    enableIf.tags.personal = true;

    # TODO: Split up
    hm = {pkgs, ...}: {
      home.packages = with pkgs; [
        gh
        glab

        jq

        fd

        hyperfine

        trash-cli

        zip
        unzip

        pdftk

        glow
      ];

      programs.btop.enable = true;

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = {
          global = {
            log_format = "-";
            log_filter = "^$";
          };
        };
      };

      # Make shell integrations explicit
      home.shell.enableShellIntegration = false;

      programs.ripgrep.enable = true;
      programs.ripgrep-all.enable = true;
      programs.bat.enable = true;

      programs.zoxide =
        shellint
        // {
          # Shadow cd
          options = ["--cmd cd"];
        };

      programs.nix-your-shell = shellint-no-bash;

      programs.eza = {
        enable = true;
        icons = "auto";
      };
      programs.fish = {
        shellAliases = ls_aliases;
        functions.ls = {
          body = ''
            if test -t 1
              eza $argv
            else
              command ls $argv
            end
          '';
          wraps = "eza";
        };
      };
      programs.bash.shellAliases = ls_aliases // {ls = "eza";}; # FIXME: Do same thing as fish

      programs.fzf = shellint;

      # NOTE: Breaks blesh
      programs.carapace = shellint-no-bash;

      # nix run github:b3nj5m1n/xdg-ninja
      home.file.".ignore".text = ''
        /.cache
        /.config
        /.local/share
        /.local/state
        /.lunarclient
        /.minecraft
        /.mozilla
        /.dotnet
        /.thunderbird
        /.steam
        /.steampid
        /.pki
        /Games
      '';
      home.file."Repos/.ignore".text = ''
        .venv/
        .idea/
        .vscode/
      '';
    };
  };
}
