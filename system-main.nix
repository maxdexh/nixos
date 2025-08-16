{G, ...}: {
  imports = G.findAutoImports "/system.nix";

  system.stateVersion = "25.05";

  programs.nix-ld.enable = true;

  # broken under flakes
  programs.command-not-found.enable = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;
  systemd.services = {
    nix-optimise.serviceConfig.ConditionACPower = true;
    nix-gc.serviceConfig.ConditionACPower = true;
  };

  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Home Manager user config
  home-manager.users.max = import ./home-main.nix;

  home-manager = {
    useGlobalPkgs = true;
    verbose = true;
    extraSpecialArgs.G = G;
  };
}
