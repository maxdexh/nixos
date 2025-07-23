{ ... }:

{
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";

    XDG_BIN_HOME = "$HOME/.local/bin";

    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    BOGOFILTER_DIR = "${XDG_DATA_HOME}/bogofilter";
    DOTNET_CLI_HOME = "${XDG_DATA_HOME}/dotnet";
    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
    # GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";  # home-manager doesnt care :c
    MATHEMATICA_USERBASE = "${XDG_CONFIG_HOME}/mathematica";
    PYTHON_HISTORY = "${XDG_STATE_HOME}/python_history";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
    NODE_REPL_HISTORY = "${XDG_STATE_HOME}/node_repl_history";
    NPM_CONFIG_INIT_MODULE = "${XDG_CONFIG_HOME}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${XDG_CACHE_HOME}/npm";
    NPM_CONFIG_TMP = "${XDG_RUNTIME_DIR}/npm";
    PNPM_HOME = "${XDG_DATA_HOME}/pnpm";

    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";

    PATH = [
      "${XDG_BIN_HOME}"
      "$CARGO_HOME/bin"
      "$HOME/.local/kitty.app/bin"
      "$HOME/.scripts/bin"
      "${PNPM_HOME}"
    ];

    # gtk.theme is dysfunctional, but this works nicely
    # It still has window decorations though.
    GTK_THEME = "Breeze:dark"; # or: "Adwaita:dark"

    # Make electron apps use wayland directly rather than running through xwayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # No idea what this was, i think it had to do with electron using wayland too?
    NIXOS_OZONE_WL = "1";
  };
}
