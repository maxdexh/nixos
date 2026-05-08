{
  parts.bash = {
    enableIf.tags.personal = true;

    hm = {...}: {
      # FIXME: Fix performance issues
      programs.bash = {
        enable = true;
        # Make sure this comes before everything, including e.g. shellAliases
        # bashrcExtra = "[[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh";
        # initExtra = "source ${host.mkNixConfigSymlink ./bashrc-extra.bash}";
        historyFile = "$XDG_STATE_HOME/bash/history";
        shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "nullglob" "checkjobs"];
        historyControl = ["ignoreboth"];
      };

      # xdg.configFile."blesh/init.sh".source = host.mkNixConfigSymlink ./blerc.bash;
    };
  };
}
