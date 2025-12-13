# Patch programs to use $XDG_DATA_HOME/firefox as the home directory
# NOTE: This also applies to its subprocesses (e.g. file pickers)
final: prev: let
  bash_set_home = dir_name:
  /* bash */
  ''
    if [[ -n "$XDG_DATA_HOME" ]]; then
      ${prev.lib.toShellVar "dataDir" dir_name}
      export HOME="$XDG_DATA_HOME/$dataDir"
    fi
  '';

  # https://github.com/NixOS/nixpkgs/blob/1786e50c5eeaffc53ae7bd71f95daefe4f2ebe1c/pkgs/build-support/setup-hooks/make-wrapper.sh#L24
  override_patch_home = {
    dirName,
    package ? prev.${dirName},
  }: package.overrideAttrs (prevAttrs: {
    nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [prev.makeWrapper];
    buildCommand = /* bash */ ''
      ${prevAttrs.buildCommand or ""}


      ##########################
      #     HOME DIR PATCH     #
      ##########################
      for f in $out/bin/*; do
        wrapProgram "$f" --run ${prev.lib.escapeShellArg (bash_set_home dirName)}
      done
      ##########################
      #   END HOME DIR PATCH   #
      ##########################
    '';
  });
in {
  lunar-client = override_patch_home {dirName = "lunar-client";};
  thunderbird = override_patch_home {dirName = "thunderbird";};
  maven = override_patch_home {dirName = "maven";};

  mathematica = override_patch_home {
    dirName = "mathematica";
    package = prev.mathematica.override {
      source = prev.requireFile {
        name = "Wolfram_14.3.0_LIN_Bndl.sh";
        # Get this hash via a command similar to this:
        # nix-store --query --hash \
        # $(nix store add-path Mathematica_XX.X.X_BNDL_LINUX.sh --name 'Mathematica_XX.X.X_BNDL_LINUX.sh')
        sha256 = "sha256:0zgl62wmrsrsza7835sl8jri8imwvlqcb303n9qpyayspjaqhhnb";
        message = ''
          Your override for Mathematica includes a different src for the installer,
          and it is missing.
        '';
        hashMode = "recursive";
      };
    };
  };
  steam = override_patch_home {dirName = "steam";};

  # TODO: Remove once xdg support is available
  firefox = override_patch_home {dirName = "firefox";};
}
