# Uses a newer version of tdf. package spec copied from nixpkgs.
# TODO: Remove when 0.4.4 releases
final: prev: {
  tdf = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "tdf";
    version = "0.4.3";

    src = prev.fetchFromGitHub {
      owner = "itsjunetime";
      repo = "tdf";
      fetchSubmodules = true;
      rev = "38b307d628609f1b8a1310ae5f0d7da6e5ed557d";
      hash = "sha256-YqUF3qQ+kmqiO1TxrQYxdjBivVl4d3YSkjKJ1fOvheg=";
    };

    cargoHash = "sha256-tfKabeXE5Q1S2yiEhRkZhi/KKJf0NOVC0lFiKcBMbNQ=";

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

    postInstall = ''
      rm "$out/bin/for_profiling"
    '';
  });
}
