{
  lib,
  ctx,
  config,
  host,
  inputs,
  ...
}: lib.mkMerge [
  (ctx.hm.set {
    programs.home-manager.enable = true;

    xdg.configFile."home-manager".source =
      config.lib.file.mkOutOfStoreSymlink host.nixConfigLocation;

    # Replace nixpkgs with this flake in commands like `nix profile install nixpkgs#package`
    # Also adds an alias so we can use `n#package`
    nix.registry = assert inputs.self?packages; {
      nixpkgs.flake = inputs.self;
      n.flake = inputs.self;
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
