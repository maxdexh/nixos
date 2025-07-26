{ ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

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

  # Disable x11
  services.xserver.enable = false;

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  # services.blueman.enable = true;

  # TODO: udev rule to prevent the keyboard & touchpad from waking the device from sleep
  # TODO: Try making the lid switch wake the device
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=5m
    '';
  };
  # Hibernate after 15min of sleep
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
    SuspendState=mem
  '';

  boot.kernelParams = [
    # Enables AMD's preferred CPU scaling driver
    # NOTE: This is set in hardware repo already
    "amd_pstate=active"

    # Enables USB autosuspend globally
    "usbcore.autosuspend=1"

    # Enables PCIe Active State Power Management (careful with some devices)
    "pcie_aspm=force"

    # Tells nvme drive not to work around acpi quirks
    # WARN: Breaks sleep on framework 7040 series
    # "nvme.noacpi=1"
  ];

  services.power-profiles-daemon.enable = true;
  services.fwupd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  services.thermald.enable = true;
  services.upower.enable = true;
  services.auto-cpufreq.enable = false; # Not needed with ppd

  # TODO: `cat /sys/class/drm/card1/device/power_dpm_state` is currently alaways "performance". Try testing:
  # systemd.services.amdgpu-power-save = {
  #   description = "Set AMD GPU to low power mode";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.ExecStart = ''
  #     echo low > /sys/class/drm/card1/device/power_dpm_force_performance_level
  #   '';
  # };
}
