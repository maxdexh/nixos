{
  config,
  pkgs,
  ctx,
  lib,
  inputs,
  custom,
  ...
}: lib.mkMerge [
  (ctx.hm.set {
    home.packages = [pkgs.home-manager];
    xdg.configFile."home-manager".source =
      config.lib.file.mkOutOfStoreSymlink custom.host.nixConfigLocation;
    # Replace nixpkgs with this flake in commands like `nix profile install nixpkgs#package`
    # TODO: Change nix path, disable channels, use nix-index
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
      "nixos-config=flake:${custom.host.nixConfigLocation}"
    ];
  })

  (ctx.os.set {
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

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Install firefox.
    programs.firefox.enable = true;

    security.polkit.enable = true;

    # enable bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  })
]
