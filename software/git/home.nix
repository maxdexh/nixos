{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Max Dexheimer";
    userEmail = "maxdexh03@gmail.com";
    aliases = {
      ca = "!git add -A && git commit"; # commit absorbs remaining arguments
      s = "status";
      p = "push";
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
