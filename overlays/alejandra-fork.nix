final: prev: {
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/al/alejandra/package.nix
  # https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo
  alejandra = prev.rustPlatform.buildRustPackage {
    pname = "alejandra";
    version = "4.0.0";

    src = prev.fetchFromGitHub rec {
      name = "alejandra-fork-${rev}"; # https://discourse.nixos.org/t/fetchfromgithub-doesnt-fetch-new-files-when-i-update-the-rev/15312/5
      owner = "maxdexh";
      repo = "alejandra";
      fetchSubmodules = true;
      hash = "sha256-2gdS7j+FTpxKETUiANeOQMfSmabsy3cS9+4hqC5IyMI=";
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
