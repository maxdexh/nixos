final: prev: {
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
