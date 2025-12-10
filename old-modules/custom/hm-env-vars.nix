{
  lib,
  custom,
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

  # Use systemd for home vars. can be changed for hosts without systemd.
  config.systemd.user.sessionVariables = custom.sessionVars;
}
