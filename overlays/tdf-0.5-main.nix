# Uses a newer version of tdf. package spec copied from nixpkgs.
# TODO: Remove when 0.5 releases
final: prev: {
  tdf = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "tdf";
    version = "0.4.3";

    src = prev.fetchFromGitHub rec {
      name = "tdf-${rev}"; # https://discourse.nixos.org/t/fetchfromgithub-doesnt-fetch-new-files-when-i-update-the-rev/15312/5
      owner = "itsjunetime";
      repo = "tdf";
      fetchSubmodules = true;
      rev = "55e0c2b33f2d1b9930533a2c962a3283e00b7bcc";
      hash = "sha256-l3oQCFMCs+cXSBERHneJvto2MOB+OzKBOaGB32uLtW8=";
    };

    cargoHash = "sha256-zOuHpLdWvuS5OKq1k7wvWxw+fZtCV78SnQPCxMU8Wws=";

    nativeBuildInputs = [prev.pkg-config];

    buildInputs = [
      prev.rustPlatform.bindgenHook
      prev.cairo
    ];

    # Tests depend on cpuprofiler, which is not packaged in nixpkgs
    doCheck = false;

    # requires nightly features (feature(portable_simd))
    RUSTC_BOOTSTRAP = true;

    meta = {
      description = "Tui-based PDF viewer";
      homepage = "https://github.com/itsjunetime/tdf";
      license = prev.lib.licenses.agpl3Only;
      maintainers = with prev.lib.maintainers; [
        luftmensch-luftmensch
        DieracDelta
      ];
      mainProgram = "tdf";
      platforms = prev.lib.platforms.unix;
    };

    # https://github.com/NixOS/nixpkgs/pull/464661#pullrequestreview-3502067889
    postInstall = ''
      rm "$out/bin/for_profiling"
    '';
  });
}
