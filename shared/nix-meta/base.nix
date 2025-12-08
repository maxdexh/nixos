{
  lib,
  ctx,
  config,
  custom,
  inputs,
  ...
}: lib.mkMerge [
  (ctx.hm.set {
    programs.home-manager.enable = true;

    xdg.configFile."home-manager".source =
      config.lib.file.mkOutOfStoreSymlink custom.host.nixConfigLocation;

    # Replace nixpkgs with this flake in commands like `nix profile install nixpkgs#package`
    nix.registry = {
      nixpkgs.flake = assert inputs.self?packages; inputs.self;
    };
  })
  (ctx.os.set {
    nix.channel.enable = false;

    # TODO: Set via hm if not on nixos
    nix.nixPath = [
      "nixpkgs=flake:${inputs.nixpkgs}"
      # FIXME: Make this work
      # "nixpkgs-overlays=${../overlays/default.nix}"

      # NOTE: Do not set nixos-config, since tools like nixos-option assume it is non-flake
    ];
  })
]
