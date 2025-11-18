final: prev: let
  lib = prev.lib;
in {
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
  # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
  alejandra = prev.rustPlatform.buildRustPackage {
    pname = "alejandra";
    version = "4.0.0";

    # FIXME: Precompile into github release, or use flakes
    src = builtins.fetchGit {
      url = "https://github.com/maxdexh/alejandra";
      rev = "dcdc1e10450694d76fc83cb00ca4c9ba9cd0ba5d";
    };

    doCheck = false;

    cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";

    meta = {
      license = lib.licenses.unlicense;
      mainProgram = "alejandra";
    };
  };

  # Patch the swaync binary to just exit when run under KDE
  swaync = let
    base = prev.swaynotificationcenter;
    mainExe = lib.getExe base;
    mainExeName = builtins.baseNameOf mainExe;

    # https://discourse.nixos.org/t/tip-how-to-enable-dunst-for-only-select-des-with-nix/65630
    patched = prev.writeShellScriptBin mainExeName ''
      if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
        echo "SwayNC: Not starting because session is KDE Plasma."
        exit 0
      fi
      exec ${mainExe} "$@"
    '';
  in prev.symlinkJoin {
    inherit (base) name meta;
    paths = [patched base]; # NOTE: patched shadows base
  };
}
