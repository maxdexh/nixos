{
  parts.git = {
    enableIf.tags.personal = true;

    hm = {host, ...}: {
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
          pl = "pull";
          c = "commit";
          d = "diff";
          b = "branch";
          ss = "switch";
          a = "add";
          l = "log";
          rs = "reset";
          rt = "restore";
          ro = "remote";

          ca = "!git add -A && git commit";
          ce = "${ca} --amend --no-edit";
        };

        safe.directory = host.nixConfigLocation;
        init.defaultBranch = "main";
        core.editor = "nvim";
      };

      # Configure ssh keys
      home.file.".ssh/config".source = host.mkNixConfigSymlink ./ssh-config;
    };
  };
}
