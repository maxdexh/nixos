{
  ctx,
  custom,
  ...
}: ctx.hm.set {
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${custom.lib.mkNixConfigSymlink ./bashrc-extra.bash}"
    '';
    historyFile = "$XDG_STATE_HOME/bash/history";
    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];
    historyControl = ["ignoreboth"];
  };
}
