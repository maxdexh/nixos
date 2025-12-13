{
  overlays.swaync-no-kde = final: prev: {
    # Patch the swaync binary to just exit when run under KDE
    swaync = let
      base = prev.swaynotificationcenter;
      mainExe = prev.lib.getExe base;
      mainExeName = builtins.baseNameOf mainExe;

      # https://discourse.nixos.org/t/tip-how-to-enable-dunst-for-only-select-des-with-nix/65630
      patched = prev.writeShellScriptBin mainExeName ''
        if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
          echo "SwayNC: Not starting because session is KDE Plasma."
          exit 0
        fi
        exec ${mainExe} $@
      '';
    in prev.symlinkJoin {
      inherit (base) name meta;
      paths = [patched base]; # NOTE: patched shadows base
    };
  };
}
