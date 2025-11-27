{
  config,
  pkgs,
  ctx,
  ...
}: ctx.hm.set {
  home.packages = with pkgs; [rustup];
  # TODO: Try rustix
  # home.packages = [
  #   (pkgs.fenix.complete.withComponents [
  #     "cargo"
  #     "clippy"
  #     "rust-src"
  #     "rustc"
  #     "rustfmt"
  #   ])
  #   pkgs.rust-analyzer-nightly
  # ];
  # NOTE: This is like home.sessionVariables (passed via .profile), which might not work outside of shells
  home.sessionPath = ["${config.xdg.dataHome}/cargo/bin"];
  custom.sessionVars = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };
}
