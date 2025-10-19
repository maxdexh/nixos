{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [python3 mypy];

  programs.uv = {
    enable = true;
    settings = {python-preference = "only-managed";};
  };

  systemd.user.sessionVariables = {
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
  };
}
