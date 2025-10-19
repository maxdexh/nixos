{G, ...}: {
  imports = G.findAutoImports "system.nix";

  system.stateVersion = "25.05";

  programs.nix-ld.enable = true;

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
  # TODO: Consider using standalone hm, with synced nixpkgs instance
  home-manager.users.max = import ./home-main.nix;

  home-manager = {
    useGlobalPkgs = true; # TODO: Where does this matter? Possibly for hyprland?
    verbose = true;
    extraSpecialArgs.G = G;
  };
}
