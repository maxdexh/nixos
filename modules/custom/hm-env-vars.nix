{
  parts.hm-env-vars = {
    tags = ["personal"];

    hm = {
      lib,
      config,
      ...
    }: {
      options.custom.sessionVars = lib.mkOption {
        default = {};
        type = lib.types.anything;
      };

      # Use systemd for home vars. can be changed for hosts without systemd.
      config.systemd.user.sessionVariables = config.custom.sessionVars;
    };
  };
}
