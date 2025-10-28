{
  lib,
  host,
  config,
  ...
}: {
  options.custom.sessionVars = lib.mkOption {
    default = {};
    type = with lib.types;
      lazyAttrsOf (oneOf [
        str
        path
        int
        float
      ]);
  };

  # Use systemd on normal hosts, the shell on termux
  config.systemd.sessionVariables = lib.mkIf (!host.termux) config.custom.sessionVars;
  config.home.sessionVariables = lib.mkIf host.termux config.custom.sessionVars;
}
