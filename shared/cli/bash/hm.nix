{
  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bashrc-extra;
    historyFile = "$XDG_STATE_HOME/bash/history";
    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];
    historyControl = ["ignoreboth"];
  };
}
