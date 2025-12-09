{
  config,
  pkgs,
  ctx,
  ...
}: ctx.hm.set {
  home.packages = with pkgs; [python3 mypy];

  programs.uv = {
    enable = true;
    settings = {python-preference = "only-managed";};
  };

  custom.sessionVars = {
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
  };
}
