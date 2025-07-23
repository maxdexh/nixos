{ config, ... }:

{
  home.sessionVariables = {
    BOGOFILTER_DIR = "${config.xdg.dataHome}/bogofilter";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    MATHEMATICA_USERBASE = "${config.xdg.configHome}/mathematica";
    ZDOTDIR = "${config.xdg.configHome}/zsh";
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "\${XDG_RUNTIME_DIR}/npm";
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";

    # GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";  # home-manager doesnt care :c
  };
}
