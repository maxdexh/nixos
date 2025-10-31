{homeSpecialArgs, ...}: {
  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";

  # Configure home-manager
  home-manager = {
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
    extraSpecialArgs = homeSpecialArgs;

    config = {...}: {
      # Read the changelog before changing this value
      home.stateVersion = "24.05";

      # imports = host_auto_imports host mod_kinds.HOME;
    };
  };
}
