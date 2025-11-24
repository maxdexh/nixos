final: prev: {
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
  # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
  alejandra = prev.rustPlatform.buildRustPackage {
    pname = "alejandra";
    version = "4.0.0";

    # FIXME: Precompile into github release, and use flakes
    src = builtins.fetchGit {
      url = "https://github.com/maxdexh/alejandra";
      rev = "dcdc1e10450694d76fc83cb00ca4c9ba9cd0ba5d";
    };

    doCheck = false;

    cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";

    meta = {
      license = prev.lib.licenses.unlicense;
      mainProgram = "alejandra";
    };
  };
}
