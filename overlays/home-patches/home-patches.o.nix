final: prev: let
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

  # Patch firefox to use $XDG_DATA_HOME/firefox as the home directory
  # NOTE: This also applies to its subprocesses (e.g. file pickers) and to the default Downloads directory
  firefox = prev.firefox.overrideAttrs (prevAttrs: {
    buildCommand = /* bash */ ''
      ${prevAttrs.buildCommand}


      ######################
      #                    #
      #   HOME DIR PATCH   #
      #                    #
      ######################

      mv "$out/bin/firefox" "$out/bin/.firefox-real"
      cat <<EOF >"$out/bin/firefox"
      if [[ -n "\$XDG_DATA_HOME" ]]; then
        export HOME="\$XDG_DATA_HOME/firefox"
      fi
      exec "$out/bin/.firefox-real" $@
      EOF
      chmod +x "$out/bin/firefox"

      ##########################
      #                        #
      #   END HOME DIR PATCH   #
      #                        #
      ##########################
    '';
  });
}
