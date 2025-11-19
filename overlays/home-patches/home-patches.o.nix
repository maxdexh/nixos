# Patch programs to use $XDG_DATA_HOME/firefox as the home directory
# NOTE: This also applies to its subprocesses (e.g. file pickers)
# TODO: Symlink download directories
final: prev: let
  patch_home_wrap_program_run = data_dir: prev.lib.escapeShellArg /* bash */ ''
    if [[ -n "$XDG_DATA_HOME" ]]; then
      export HOME="$XDG_DATA_HOME/"${prev.lib.escapeShellArg data_dir}
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
        wrapProgram "$f" --run ${patch_home_wrap_program_run name}
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
