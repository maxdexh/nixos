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
  ];

  programs.ripgrep.enable = true;
  programs.bat.enable = true;

  programs.zoxide = shellint // {
    # Shadow cd
    options = [ "--cmd cd" ];
  };

  programs.nix-your-shell = shellint-no-bash;

  programs.eza = shellint // {
    # TODO: Icons, git, etc.
  };

  programs.fzf = shellint;

  programs.carapace = shellint;

  # programs.nix-index = enable-shellint;

  # programs.mcfly = enable-shellint;

  # programs.scmpuff = enable-shellint;
}
