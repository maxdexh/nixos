{
  parts.rust = {
    tags = ["default"];

    hm = {
      config,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [rustup];
      # NOTE: This is like home.sessionVariables (passed via .profile), which might not work outside of shells
      home.sessionPath = ["${config.xdg.dataHome}/cargo/bin"];
      custom.sessionVars = {
        CARGO_HOME = "${config.xdg.dataHome}/cargo";
        RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      };
    };
  };
}
