{
  overlays.cfg-package-utils = final: prev: {
    cfgUtils = assert !(prev ? cfgUtils); {
      # TODO: Do escaping like hm, to make store names more readable
      mkSymlink = path: let
        path_str = toString path;
      in
        prev.runCommandLocal path_str {} "ln -s ${prev.lib.escapeShellArg path_str} $out";

      writeFishApplication = {
        name,
        text,
        runtimeInputs ? [],
        inheritPath ? true,
        # TODO: runtimeEnv
      }: prev.writeTextFile {
        inherit name;
        executable = true;
        destination = "/bin/${name}";
        meta.mainProgram = name;

        text = /* fish */ ''
          #!${prev.lib.getExe prev.fish}

          set ${
            if inheritPath
            then "--prepend"
            else ""
          } PATH (string split ':' -- "${
            prev.lib.makeBinPath runtimeInputs
          }")

          ${text}
        '';
      };
    };
  };
}
