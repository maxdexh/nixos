{inputs, ...}: {
  parts.nix-meta-cfg = {
    enableIf.tags.personal = true;

    hm = {
      host,
      pkgs,
      ...
    }: {
      # NOTE: This currently does nothing when installing hm as a nixos module.
      # One must install pkgs.home-manager manually to switch to a standalone hm setup.
      programs.home-manager.enable = true;

      xdg.configFile."home-manager".source = host.nixConfigSymlink;

      # Replace nixpkgs with this flake in commands like `nix profile install nixpkgs#package`
      # Also adds an alias so we can use `n#package`
      nix.registry = assert inputs.self?packages; rec {
        nixpkgs.to = n.to;
        n.to = {
          type = "path";
          path = toString pkgs.path;
        };
        n.from = {
          type = "indirect";
          id = "n";
        };
      };
    };

    nixos = {
      config,
      host,
      ...
    }: {
      nix.settings.trusted-users = map (user: config.users.users.${user.username}.name) (builtins.attrValues host.users);

      nix.channel.enable = false;

      # TODO: Set via hm if not on nixos
      nix.nixPath = [
        "nixpkgs=flake:${inputs.nixpkgs}"
        # FIXME: Make this work
        # "nixpkgs-overlays=${../overlays/default.nix}"

        # NOTE: Do not set nixos-config, since tools like nixos-option assume it is non-flake
      ];
    };
  };
}
