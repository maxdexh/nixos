final: prev: let
  # https://wiki.nixos.org/wiki/Nix_Cookbook#Wrapping_packages
  patch_home = {
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
  lunar-client = patch_home {name = "lunar-client";};
  thunderbird = patch_home {name = "thunderbird";};
}
