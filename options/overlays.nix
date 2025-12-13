{
  lib,
  config,
  ...
}: {
  # TODO: Merge overlays
  options.overlays = lib.mkOption {
    # https://github.com/NixOS/nixpkgs/blob/09eb77e94fa25202af8f3e81ddc7353d9970ac1b/nixos/modules/misc/nixpkgs.nix#L47
    type = lib.types.attrsOf (lib.mkOptionType {
      name = "nixpkgs-overlay";
      description = "nixpkgs overlay";
      check = lib.isFunction;
      merge = lib.mergeOneOption;
    });
    default = {};
  };

  options.homeDirOverlays = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({
      name,
      config,
      ...
    }: {
      options.dirName = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      options.package = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = prev: prev.${config.pkgName};
      };
      options.pkgName = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
    }));
  };

  config.overlays.s__homeDirOverlays = final: prev: let
    apply = {
      dirName,
      package,
      pkgName,
    }: {
      name = pkgName;
      value = let
        bash_set_home = /* bash */ ''
          if [[ -n "$XDG_DATA_HOME" ]]; then
            ${prev.lib.toShellVar "dataDir" dirName}
            export HOME="$XDG_DATA_HOME/$dataDir"
          fi
        '';
      in (package prev).overrideAttrs (prevAttrs: {
        # https://github.com/NixOS/nixpkgs/blob/1786e50c5eeaffc53ae7bd71f95daefe4f2ebe1c/pkgs/build-support/setup-hooks/make-wrapper.sh#L24
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [prev.makeWrapper];

        buildCommand = /* bash */ ''
          ${prevAttrs.buildCommand or ""}

          ##########################
          #     HOME DIR PATCH     #
          ##########################
          for f in $out/bin/*; do
            wrapProgram "$f" --run ${prev.lib.escapeShellArg bash_set_home}
          done
          ##########################
          #   END HOME DIR PATCH   #
          ##########################
        '';
      });
    };
  in builtins.listToAttrs (map apply (builtins.attrValues config.homeDirOverlays));
}
