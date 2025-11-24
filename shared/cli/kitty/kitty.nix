{
  pkgs,
  lib,
  config,
  ctx,
  ...
}:
lib.flip lib.pipe [
  lib.mkMerge
  (lib.mkIf config.custom.host.fullDesktop)
] [
  (ctx.os.set {
    environment.systemPackages = with pkgs; [kitty];
  })

  (ctx.hm.set {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = "include ${config.lib.custom.mkNixConfigSymlink ./kitty.conf}";
    };

    home.packages = with pkgs; [
      (rustPlatform.buildRustPackage (finalAttrs: {
        pname = "tdf";
        version = "0.4.3";

        src = fetchFromGitHub {
          owner = "maxdexh";
          repo = "tdf";
          fetchSubmodules = true;
          rev = "5fddedaebb56a120bf373c2d2709a7c55dcdf91d";
          hash = "sha256-ZC7yQt2ssbRWP7EP7QBrLe8mN9Z9Va4eLivEP/78YpM=";
        };

        cargoHash = "sha256-8JGiKlVr41YbG+mI/S0xPByKa4pwAH4cDVlznRcfCxE=";

        nativeBuildInputs = [pkg-config];

        buildInputs = [
          rustPlatform.bindgenHook
          cairo
        ];

        # Tests depend on cpuprofiler, which is not packaged in nixpkgs
        doCheck = false;

        # requires nightly features (feature(portable_simd))
        RUSTC_BOOTSTRAP = true;

        meta = {
          description = "Tui-based PDF viewer";
          homepage = "https://github.com/itsjunetime/tdf";
          license = lib.licenses.agpl3Only;
          maintainers = with lib.maintainers; [
            luftmensch-luftmensch
            DieracDelta
          ];
          mainProgram = "tdf";
          platforms = lib.platforms.unix;
        };
      }))
    ];
  })
]
