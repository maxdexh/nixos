{config, ...}: {
  custom.sessionVars = {
    BOGOFILTER_DIR = "${config.xdg.dataHome}/bogofilter";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    MATHEMATICA_USERBASE = "${config.xdg.configHome}/mathematica";
    ZDOTDIR = "${config.xdg.configHome}/zsh";

    GTK2_RC_FILES = config.gtk.gtk2.configLocation;
    XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
  };
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtkrc-2.0";
}
