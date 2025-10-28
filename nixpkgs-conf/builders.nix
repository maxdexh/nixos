{
  nixpkgs.overlays = [
    (final: prev: {
      # https://github.com/NixOS/nixpkgs/blob/37a4fc0bb6425e8f0c577604bdcdb8ddb2873fa7/pkgs/build-support/trivial-builders/default.nix#L244
      helpers.writeFishApplication = {
        name,
        text,
        runtimeInputs ? [],
      }:
        final.writeTextFile {
          inherit name;
          executable = true;
          destination = "/bin/${name}";
          meta.mainProgram = name;

          text =
            # fish
            ''
              #!${final.lib.getExe final.fish}

              set --prepend PATH (string split ':' -- "${
                final.lib.makeBinPath runtimeInputs
              }")

              ${text}
            '';
        };
    })
  ];
}
