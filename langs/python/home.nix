{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ python3 ];

  programs.uv = {
    enable = true;
    settings = { python-preference = "only-managed"; };
  };

  home.sessionVariables = {
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
  };
}
