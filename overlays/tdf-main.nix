# Uses a newer version of tdf. package spec copied from nixpkgs.
# TODO: Use overrides instead (see nixpkgs manual for how to do this with rust)
final: prev: {
  tdf = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "tdf";
    version = "0.5.0";

    src = prev.fetchFromGitHub rec {
      name = "tdf-${rev}"; # https://discourse.nixos.org/t/fetchfromgithub-doesnt-fetch-new-files-when-i-update-the-rev/15312/5
      owner = "itsjunetime";
      repo = "tdf";
      fetchSubmodules = true;
      rev = "d5d62c81a30a80383380de6567e436bd8cf1b731";
      hash = "sha256-AZ1ISZuPnU2foaEJ9gxCCDoeQJAWiXYRUp3l15rH0po=";
    };

    cargoHash = "sha256-lGbsb3hlFen0tXBVLbm8+CE5dddv6Ner4YSAvAd3/ug=";

    nativeBuildInputs = [prev.pkg-config];

    buildInputs = [
      prev.rustPlatform.bindgenHook
      prev.cairo
    ];

    # Tests depend on cpuprofiler, which is not packaged in nixpkgs
    doCheck = false;

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
