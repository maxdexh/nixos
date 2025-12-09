{
  pkgs,
  lib,
  ...
}: lib.setAttrByPath ["custom" "lib"] {
  # https://github.com/NixOS/nixpkgs/blob/37a4fc0bb6425e8f0c577604bdcdb8ddb2873fa7/pkgs/build-support/trivial-builders/default.nix#L244
  writeFishApplication = {
    name,
    text,
    runtimeInputs ? [],
    inheritPath ? true,
    # TODO: runtimeEnv
  }: pkgs.writeTextFile {
    inherit name;
    executable = true;
    destination = "/bin/${name}";
    meta.mainProgram = name;

    text = /* fish */ ''
      #!${lib.getExe pkgs.fish}

      set ${
        if inheritPath
        then "--prepend"
        else ""
      } PATH (string split ':' -- "${
        lib.makeBinPath runtimeInputs
      }")

      ${text}
    '';
  };
}
