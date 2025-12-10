{
  pkgs,
  cfgUtils,
  ctx,
  ...
}: ctx.hm.set {
  home.packages = with pkgs; [
    (writeShellScriptBin "start" ''
      eval "$@" &>/dev/null &
      disown
    '')
    (cfgUtils.writeShellScriptBin "list-fonts" ''
      fc-list | sed 's/.*:\s*\([^:]*\):.*/\1/' | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq
    '')
    (cfgUtils.writeFishApplication {
      name = "find-mimes";
      text = /* fish */ ''
        set -l xdg_dirs (string split ':' -- $XDG_DATA_DIRS)
        set -l mime_dirs (command ls -d -- $xdg_dirs/mime 2>/dev/null)
        for mime_dir in $mime_dirs
          pushd $mime_dir
          find . -name '*.xml'
          popd
        end | string sub -s 3 --end=-4 | sort | uniq
      '';
    })
    (cfgUtils.writeFishApplication {
      name = "find-unsynced";
      text = builtins.readFile ./find-unsynced.fish;
      runtimeInputs = [pkgs.fd];
    })
  ];
}
