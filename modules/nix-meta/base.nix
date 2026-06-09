{inputs, ...}: {
  parts.nix-meta-cfg = {
    enableIf.tags.personal = true;

    hm = {
      host,
      config,
      lib,
      ...
    }: {
      # NOTE: This currently does nothing when installing hm as a nixos module.
      # One must install pkgs.home-manager manually to switch to a standalone hm setup.
      programs.home-manager.enable = true;

      xdg.configFile."home-manager".source = host.nixConfigSymlink;

      # Replace nixpkgs with this flake in commands like `nix profile install nixpkgs#package`
      # Also adds an alias so we can use `n#package`
      nix.registry = {
        n.to = {
          type = "indirect";
          id = "nixpkgs";
        };
        # mimic nixpkgs.flake.source (not available in hm)
        nixpkgs = lib.mkIf (!host.nixos.enable) {
          nixpkgs = {
            exact = true;
            flake = null;
            from = {
              id = "nixpkgs";
              type = "indirect";
            };
            to = {
              path = "${inputs.self}";
              type = "path";
            };
          };
        };
      };
      # mimic nixpkgs.flake.source (not available in hm)
      nix.nixPath = lib.mkIf (!host.nixos.enable) [
        "nixpkgs=flake:nixpkgs"
      ];
    };

    nixos = {
      config,
      host,
      lib,
      ...
    }: {
      nix.settings.trusted-users = map (user: config.users.users.${user.username}.name) (builtins.attrValues host.users);

      nixpkgs.flake.source = assert inputs.self?packages; lib.mkForce "${inputs.self}";

      nix.channel.enable = false;
    };
  };
}
