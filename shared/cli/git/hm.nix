{config, ...}: {
  programs.git = {
    enable = true;
    userName = "Max Dexheimer";
    userEmail = "maxdexh03@gmail.com";
    aliases = rec {
      # TODO: Use multi-word shell aliases (via expand function) for these instead
      s = "status";
      p = "push";
      c = "commit";
      d = "diff";
      a = "add";
      l = "log";
      rs = "reset";
      rt = "restore";
      ro = "remote";

      whyy = "!echo 'test'";

      ca = "!git add -A && git commit";
      ce = "${ca} --amend --no-edit";
      nca = "${ca} && nixos-rebuild switch --use-remote-sudo";
      nce = "${ce} && nixos-rebuild switch --use-remote-sudo";
    };
    extraConfig = {
      safe.directory = "/etc/nixos/";
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  # Configure ssh keys
  home.file.".ssh/config".source = config.lib.custom.mkNixConfigSymlink ./ssh-config;
}
