{
  ctx,
  custom,
  pkgs,
  ...
}: ctx.hm.set {
  programs.bash = {
    enable = true;
    # Make sure this comes before everything, including e.g. shellAliases
    bashrcExtra = "[[ $- == *i* ]] && source ${pkgs.blesh}/share/blesh/ble.sh";
    initExtra = "source ${custom.lib.mkNixConfigSymlink ./bashrc-extra.bash}";
    historyFile = "$XDG_STATE_HOME/bash/history";
    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];
    historyControl = ["ignoreboth"];
  };

  xdg.configFile."blesh/init.sh".source = custom.lib.mkNixConfigSymlink ./blerc.bash;
}
