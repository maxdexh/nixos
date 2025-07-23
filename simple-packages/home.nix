{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # languages
    rustup # mutually exclusive with the other rust packages: rust-analyzer, cargo, rustc
    nodejs
    pnpm # trash

    # cli apps
    fd # better find
    gh # github cli
    glab # gitlab cli
    pferd # audi famam
    jq # json

    # gui apps
    obs-studio
    gimp
    vscode
    brave
    thunderbird
    gnome-system-monitor
    discord

    # disk utils
    baobab
    gparted

    # pdf
    zathura
    tdf

    # games
    prismlauncher
    lunar-client

    # These packages are required for kcmshell to work
    kdePackages.kirigami-addons
    kdePackages.kitemmodels
  ];

  programs.ripgrep.enable = true;
  programs.bat.enable = true;
}
