{
  config,
  pkgs,
  ...
}:
# Mason uses npm :/
{
  home.packages = with pkgs; [nodejs pnpm];

  home.sessionVariables = {
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "\${XDG_RUNTIME_DIR}/npm";
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
  };
}
