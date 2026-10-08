{
  parts.base-os = {
    enableIf.tags.basic = true;
    nixos = {...}: {
      # Bootloader.
      # TODO: Consider moving
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Set your time zone.
      time.timeZone = "Europe/Berlin";

      i18n = {
        defaultLocale = "en_US.UTF-8";

        # FIXME: Use british date format with german time format?
        # Some apps decide language for date based on time locale.
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

      # TODO: Consider moving
      security.polkit.enable = true;

      programs.neovim = {
        enable = true;
        defaultEditor = true; # TODO: remove?
      };
    };
  };

  # FIXME: Most of this should be moved elsewhere
  parts.base-os-desktop = {
    enableIf.tags.fullDesktop = true;
    nixos = {
      pkgs,
      host,
      ...
    }: {
      # Use latest stable kernel
      # boot.kernelPackages = pkgs.linuxPackages_latest;

      # Install firefox.
      programs.firefox.enable = true;

      boot.supportedFilesystems = {
        ntfs = true;
      };

      environment.systemPackages = with pkgs; [
        wl-clipboard
      ];

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # enable bluetooth
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = !host.checkCond {tags.laptop = true;};
      };

      # Enable networking
      networking.networkmanager.enable = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;
    };
  };
}
