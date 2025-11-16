{
  lib,
  config,
  host,
  ctx,
  ...
}: ctx.hm.set {
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
  config.systemd.user.sessionVariables = lib.mkIf (!host.termux) config.custom.sessionVars;
  config.home.sessionVariables = lib.mkIf host.termux config.custom.sessionVars;
}
