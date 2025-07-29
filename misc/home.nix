{ config, pkgs, ... }:

{
  # Misc applications
  home.packages = with pkgs; [
    # disk utils
    baobab
    gparted

    # games
    prismlauncher
    # lunar-client

    # gui apps
    obs-studio
    gimp
    vscode
    brave
    thunderbird
    gnome-system-monitor
    discord
    zathura

    (pkgs.writeShellScriptBin "start" ''
      eval "$@" &>/dev/null &
      disown
    '')
    (pkgs.writeShellScriptBin "list-fonts" ''
      fc-list | sed 's/.*:\s*\([^:]*\):.*/\1/' | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq
    '')
  ];

  # Keep home directory clean (in case we use these through nix-shell or nix-env)
  home.sessionVariables = {
    BOGOFILTER_DIR = "${config.xdg.dataHome}/bogofilter";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    MATHEMATICA_USERBASE = "${config.xdg.configHome}/mathematica";
    ZDOTDIR = "${config.xdg.configHome}/zsh";

    # GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";  # home-manager doesnt care :c
  };
}
