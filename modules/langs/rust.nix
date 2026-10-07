{
  parts.rust = {
    enableIf.tags.cli = true;

    hm = {
      config,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [
        rustup
        # Need gcc because nvim config implicitly depends on cc
        # FIXME: Compile nvim config in nix shell and remove this
        gcc
      ];
      # NOTE: This is like home.sessionVariables (passed via .profile), which might not work outside of shells
      home.sessionPath = ["${config.xdg.dataHome}/cargo/bin"];
      custom.sessionVars = {
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      };
    };
  };
}
