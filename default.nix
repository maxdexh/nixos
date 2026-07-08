# Entry point for `import <nixpkgs>`.
args: let
  # https://github.com/nix-community/nixd/issues/762
  flake = builtins.${"getFlake"} (toString ./.);

  flake-overlays = builtins.attrValues flake.overlays;

  # NOTE: This way of doing things makes things like .config/nixpkgs/overlays.nix stop working
  # NOTE: Only overlays are applied; we could instead mimic top-level/impure.nix to create a
  # suitable wrapper around flake.packages.${currentSystem} directly
  args-with-overlays = args // {overlays = flake-overlays ++ args.overlays or [];};
in
  import <nixpkgs-base> args-with-overlays
