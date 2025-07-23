{ config, ... }:

{
  home.sessionVariables = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };
  home.sessionPath = [ "${config.xdg.dataHome}/cargo/bin" ];

  xdg.dataFile = {
    # use x86 stable as default
    "rustup/settings.toml".source = ./settings.toml;
  };
}
