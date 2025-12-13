{inputs, ...}: {
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
  # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
  # FIXME: Provide a better flake.nix over there instead.
  overlays.alejandra-fork = final: prev: {
    alejandra = prev.rustPlatform.buildRustPackage {
      pname = "alejandra";
      version = "4.0.0";
      src = inputs.alejandra-fork;
      doCheck = false;
      cargoHash = "sha256-IX4xp8llB7USpS/SSQ9L8+17hQk5nkXFP8NgFKVLqKU=";
      meta = {
        license = prev.lib.licenses.unlicense;
        mainProgram = "alejandra";
      };
    };
  };
}
