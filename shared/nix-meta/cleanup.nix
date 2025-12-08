{ctx, ...}:
ctx.os.set {
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
}
// ctx.hm.set {
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    store.cleanup = false;
  };
}
