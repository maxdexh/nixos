{...}: {
  programs.git = {
    enable = true;
    userName = "Max Dexheimer";
    userEmail = "maxdexh03@gmail.com";
    aliases = rec {
      s = "status";
      p = "push";
      c = "commit";
      d = "diff";
      a = "add";
      l = "log";

      whyy = "!echo 'test'";

      ca = "!git add -A && git commit";
      ce = "${ca} --amend --no-edit";
      nca = "${ca} && sudo nixos-rebuild switch";
      nce = "${ce} && sudo nixos-rebuild switch";
    };
    extraConfig = {
      safe.directory = "/etc/nixos/";
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };

  # Configure ssh keys
  home.file.".ssh/config".source = ./ssh-config;
}
