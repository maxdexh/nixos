# Patch programs to use $XDG_DATA_HOME/firefox as the home directory
# NOTE: This also applies to its subprocesses (e.g. file pickers)
# TODO: Symlink download directories
final: prev: let
  patch_home_wrap_program_run = data_dir: prev.lib.escapeShellArg /* bash */ ''
    if [[ -n "$XDG_DATA_HOME" ]]; then
      local ${prev.lib.toShellVar "dataDir" data_dir}
      export HOME="$XDG_DATA_HOME/$dataDir"
    fi
  '';

  # https://github.com/NixOS/nixpkgs/blob/1786e50c5eeaffc53ae7bd71f95daefe4f2ebe1c/pkgs/build-support/setup-hooks/make-wrapper.sh#L24
  override_patch_home = {
    data_dir,
    package,
  }: package.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [prev.makeWrapper];
    buildCommand = /* bash */ ''
      ${prevAttrs.buildCommand or ""}


      ##########################
      #     HOME DIR PATCH     #
      ##########################
      for f in $out/bin/*; do
        wrapProgram "$f" --run ${patch_home_wrap_program_run data_dir}
      done
      ##########################
      #   END HOME DIR PATCH   #
      ##########################
    '';
  });

  # https://wiki.nixos.org/wiki/Nix_Cookbook#Wrapping_packages
  join_patch_home = {
    name,
    pkg ? prev.${name},
  }: prev.runCommand name {} ''
    mkdir $out
    # Link every top-level folder the package
    ln -s ${pkg}/* $out
    # Except the bin folder
    rm $out/bin
    mkdir $out/bin

    # We create a patched wrapper for every binary
    for f in ${pkg}/bin/*; do
      local fOut="$out/bin/''${f#"${pkg}/bin/"}"
      cat <<EOF >"$fOut"
    if [[ -n "\$XDG_DATA_HOME" ]]; then
      export HOME="\$XDG_DATA_HOME/${name}"
    fi
    exec "$f" $@
    EOF
      chmod +x "$fOut"
    done
  '';
in {
  lunar-client = join_patch_home {name = "lunar-client";};
  thunderbird = join_patch_home {name = "thunderbird";};

  # TODO: Change default download dir via policy
  firefox = override_patch_home {
    data_dir = "firefox";
    package = prev.firefox;
  };
}
