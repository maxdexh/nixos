{...}: {
  parts.nix-meta-cfg = {
    enableIf.tags.personal = true;

    hm = {host, ...}: {
      # NOTE: This currently does nothing when installing hm as a nixos module.
      # One must install pkgs.home-manager manually to switch to a standalone hm setup.
      programs.home-manager.enable = true;

      # NOTE: This conflicts with any attempt to put this config at that path
      xdg.configFile."home-manager".source = host.nixConfigSymlink;

      # Add an alias so we can use `n#package`
      # See also: ./nixpkgs-override.nix
      nix.registry = {
        n.to = {
          type = "indirect";
          id = "nixpkgs";
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
    };
  };
}
