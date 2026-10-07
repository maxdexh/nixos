{
  parts.python = {
    enableIf.tags.cli = true;

    hm = {config, ...}: {
      programs.uv = {
        enable = true;
        settings = {python-preference = "only-managed";};
      };

      custom.sessionVars = {
        PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
      };
    };
  };
}
