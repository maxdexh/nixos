# Patch programs to use $XDG_DATA_HOME/firefox as the home directory
# NOTE: This also applies to its subprocesses (e.g. file pickers)
final: prev: let
  bash_set_home = data_dir: /* bash */ ''
    if [[ -n "$XDG_DATA_HOME" ]]; then
      ${prev.lib.toShellVar "dataDir" data_dir}
      export HOME="$XDG_DATA_HOME/$dataDir"
    fi
  '';

  # https://github.com/NixOS/nixpkgs/blob/1786e50c5eeaffc53ae7bd71f95daefe4f2ebe1c/pkgs/build-support/setup-hooks/make-wrapper.sh#L24
  override_patch_home = {
    name,
    package ? prev.${name},
  }: package.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [prev.makeWrapper];
    buildCommand = /* bash */ ''
      ${prevAttrs.buildCommand or ""}


      ##########################
      #     HOME DIR PATCH     #
      ##########################
      for f in $out/bin/*; do
        wrapProgram "$f" --run ${prev.lib.escapeShellArg (bash_set_home name)}
      done
      ##########################
      #   END HOME DIR PATCH   #
      ##########################
    '';
  });

in {
  lunar-client = override_patch_home {name = "lunar-client";};
  thunderbird = override_patch_home {name = "thunderbird";};

  # TODO: Change default download dir via policy
  firefox = override_patch_home {name = "firefox";};
}
