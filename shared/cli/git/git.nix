{
  custom,
  ctx,
  ...
}: ctx.hm.set {
  programs.git = {
    enable = true;
  };
  programs.git.settings = {
    user.name = "Max Dexheimer";
    user.email = "maxdexh03@gmail.com";
    alias = rec {
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
    };

    safe.directory = "/etc/nixos/";
    init.defaultBranch = "main";
    core.editor = "nvim";
  };

  # Configure ssh keys
  home.file.".ssh/config".source = custom.lib.mkNixConfigSymlink ./ssh-config;
}
