{ pkgs, ... }:

let
  shellint-no-bash = {
    enable = true;
    enableFishIntegration = true;
  };

  shellint = { enableBashIntegration = true; } // shellint-no-bash;
in {
  home.packages = with pkgs; [
    gh
    glab

    jq

    fd

    trash-cli

    zip
    unzip

    powertop
    nvme-cli
    smartmontools
  ];

  # Make shell integrations explicit
  home.shell.enableShellIntegration = false;

  programs.ripgrep.enable = true;
  programs.bat.enable = true;

  programs.zoxide = shellint // {
    # Shadow cd
    options = [ "--cmd cd" ];
  };

  programs.nix-your-shell = shellint-no-bash;

  programs.eza = {
    enable = true;
    icons = "auto";
  };
  programs.fish = {
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
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      lt = "eza --tree";
    };
  };

  programs.fzf = shellint;

  programs.carapace = shellint;

  # This sucks, but I can't be bothered.
  xdg.configFile."nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';

  # programs.nix-index = enable-shellint;

  # programs.mcfly = enable-shellint;

  # programs.scmpuff = enable-shellint;
}
