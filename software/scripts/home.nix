{ pkgs, lib, ... }:

let
  # https://github.com/NixOS/nixpkgs/blob/37a4fc0bb6425e8f0c577604bdcdb8ddb2873fa7/pkgs/build-support/trivial-builders/default.nix#L244
  writeFishApplication = { name, text, runtimeInputs ? [ ] }:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      destination = "/bin/${name}";
      meta.mainProgram = name;

      text = ''
        #!${lib.getExe pkgs.fish}

        set --append PATH (string split ':' -- "${
          lib.makeBinPath runtimeInputs
        }")

        ${text}
      '';
    };
in {
  home.packages = with pkgs; [
    (writeShellScriptBin "start" ''
      eval "$@" &>/dev/null &
      disown
    '')
    (writeShellScriptBin "list-fonts" ''
      fc-list | sed 's/.*:\s*\([^:]*\):.*/\1/' | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq
    '')
    (writeFishApplication {
      name = "find-mimes";
      text = # fish
        ''
          set -l xdg_dirs (string split ':' -- $XDG_DATA_DIRS)
          set -l mime_dirs (command ls -d -- $xdg_dirs/mime 2>/dev/null)
          for mime_dir in $mime_dirs
            pushd $mime_dir
            find . -name '*.xml'
            popd
          end | string sub -s 3 --end=-4 | sort | uniq
        '';
    })
  ];
}
