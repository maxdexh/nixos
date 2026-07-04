{inputs, ...}: let
  description = ''
    Replaces nixpkgs with this flake for the purposes of
    `import <nixpkgs>` (stable) and `nixpkgs#` (flakes).

    This means that overlays set in this flake are applied globally,
    except for other flakes that import nixpkgs by url.
    `--override-input nixpkgs nixpkgs` can be used if needed.

    The nix path override requires a `default.nix` in the flake
    that mimics `<nixpkgs>/pkgs/top-level/impure.nix` (that also
    applies the overlays)

    The nix flake override requires setting the flake's `packages`
    attribute.
  '';

  # TODO: Setup testing (`nix flake check`)

  common-cfg = {pkgs}: {
    nix.registry.nixpkgs.to = assert inputs.self?packages; {
      type = "path";
      path = "${inputs.self}";
    };
    # Sets <nixpkgs-base> to to the original packages for use by default.nix
    nix.nixPath = ["nixpkgs=flake:nixpkgs" "nixpkgs-base=${pkgs.path}"];
  };
in {
  parts.nixpkgs-override = {
    enableIf.tags.personal = true;

    inherit description;

    # use nixos to set the override if available. also disable the nixos-only
    # mechanism that does this (without overlays) automatically.
    nixos = {
      lib,
      pkgs,
      ...
    }: lib.mkMerge [
      (common-cfg {inherit pkgs;})
      {nixpkgs.flake.source = lib.mkForce null;}
    ];

    # use hm as a fallback. using lib.mkIf means that we still get errors
    # if the expected formats differ in hm (while using nixos).
    hm = {
      host,
      lib,
      pkgs,
      ...
    }: lib.mkIf (!host.nixos.enable) (common-cfg {inherit pkgs;});
  };
}
