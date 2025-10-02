{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [rustup];
  # Note that this is like home.sessionVariables (passed via .profile)
  home.sessionPath = ["${config.xdg.dataHome}/cargo/bin"];
  systemd.user.sessionVariables = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };
}
