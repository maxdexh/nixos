# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  enable-shellint-no-bash = {
    enable = true;
    enableFishIntegration = true;
  };
  enable-shellint = {
    enableBashIntegration = true;
  } // enable-shellint-no-bash;
in {
  imports = [
    # TODO: use a gitignored hardware-specific file for this
    # https://github.com/NixOS/nixos-hardware/tree/master
    <nixos-hardware/framework/13-inch/7040-amd>
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    (import "${home-manager}/nixos")
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  i18n = import ./localization.nix;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true; # "bLoAtWaRe"

  services.xserver.enable = false; # disable bloatware

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  services.blueman.enable = true;
  services.logind.lidSwitch = "suspend-then-hibernate";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
  };
  # Enabled by default on AMD
  # services.power-profiles-daemon.enable = true;

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  environment.systemPackages = with pkgs; [
    kitty # preferred terminal

    neovim # preferred editor
    wl-clipboard # wayland clipboard cli, system-level due to use by neovim
    # xclip       # x11 clipboard cli, not needed because programs.xserver.enabled = false

    fish # preferred shell
    trash-cli # safer rm

    gcc # compiler, sometimes useful
    python3
    uv # python, occasionally useful

    git # git

    zip
    unzip # all my homies hate tar.gz

    openvpn
  ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    kwalletmanager
    okular
  ];

  fonts.packages = with pkgs; [
    # cascadia-code
    nerd-fonts.caskaydia-mono
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Configure key remaps.
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            z = "y";
            y = "z";
            capslock = "esc";
          };
          # Assumes AltGr key combining with ä on q, ö on p, ü on y.
          # TODO: british version
          altgr = {
            a = "G-q";
            o = "G-p";
            u = "G-y";
          };
        };
      };
    };
  };
  # Fix palm rejection and disable-while-typing by telling libinput to treat the keyd virtual kb as a builtin keyboard
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  # Use neovim on a system-level.
  # TODO: Rudimentary config for sudo nvim, e.g. set shiftwidth=2, set expandtab
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # https://github.com/hyprwm/Hyprland/discussions/7923
  # https://www.reddit.com/r/hyprland/comments/1aj24qe/can_i_reproduce_scaling_for_xwayland_apps_in/
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Steam.
  programs.steam.enable = true;

  # Required to dynamically link executables, such as nvim mason binaries
  programs.nix-ld.enable = true;

  # also inherits unfree allowed
  home-manager.useGlobalPkgs = true;

  environment.sessionVariables = import ./session-vars.nix;

  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde6";
  };
  home-manager.verbose = true;

  # TODO: make home.file readonly?
  home-manager.users.max = { pkgs, ... }: {
    home = {
      # The state version is required and should stay at the version you
      # originally installed.
      stateVersion = "25.05";
      packages = with pkgs; [
        # hyprland
        waybar
        hyprshot # screenshot TODO: Alternative with stable regions + confirm
        brightnessctl
        rofi-wayland # App launcher
        xorg.xrdb # For kde-style xwayland scaling

        # languages
        rustup # mutually exclusive with the other rust packages: rust-analyzer, cargo, rustc
        nodejs
        pnpm # trash

        # cli apps
        fd # better find
        gh # github cli
        glab # gitlab cli
        pferd # audi famam
        jq # json

        # gui apps
        obs-studio
        gimp
        vscode
        brave
        thunderbird
        gnome-system-monitor
        discord

        # disk utils
        baobab
        gparted

        # pdf
        zathura
        tdf

        # games
        prismlauncher
        lunar-client

        # These packages are required for kcmshell to work
        kdePackages.kirigami-addons
        kdePackages.kitemmodels
      ];

      # Add custom scripts
      file.".scripts".source = ./Scripts;
    };
    xdg = import ./xdg.nix;

    # TODO: make this not look like shit
    services.dunst = {
      enable = true;
      # https://discourse.nixos.org/t/tip-how-to-enable-dunst-for-only-select-des-with-nix/65630
      package = pkgs.writeShellScriptBin "dunst" ''
        if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ]; then
          echo "Dunst: Not starting because session is KDE Plasma."
          exit 0
        fi
        exec ${pkgs.dunst}/bin/dunst "$@"
      '';
      configFile = ./Config/dunstrc;
    };

    programs.waybar = import ./waybar.nix;

    # TODO: https://wiki.nixos.org/wiki/Hyprland config here
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./Config/hyprland.conf;
    };

    # Adwaita-Dark doesnt seem to do anything and breeze-dark (using breeze-gtk pkg) is hopelessly broken
    # Luckily the GTK_THEME variable works flawlessly for both themes
    # gtk = {
    #   enable = true;
    #   theme = { name = "Adwaita-Dark"; };
    #   gtk3 = { extraConfig.gtk-application-prefer-dark-theme = true; };
    # };

    programs.bash = {
      enable = true;
      bashrcExtra = builtins.readFile ./Config/bashrc-extra;
      historyFile = "$XDG_STATE_HOME/bash/history";
      shellOptions =
        [ "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" ];
      historyControl = [ "ignoreboth" ];
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./Config/interactive.fish;
    };

    programs.zoxide = enable-shellint // { options = [ "--cmd cd" ]; };
    programs.nix-your-shell = enable-shellint-no-bash;
    programs.eza = enable-shellint // {
      # TODO: Icons, git, etc.
    };
    programs.fzf = enable-shellint;
    programs.carapace = enable-shellint;
    # programs.nix-index = enable-shellint;
    # programs.mcfly = enable-shellint;
    # programs.scmpuff = enable-shellint;

    programs.ripgrep.enable = true;
    programs.bat.enable = true;

    programs.git = {
      enable = true;
      userName = "Max Dexheimer";
      userEmail = "maxdexh03@gmail.com";
      aliases = {
        ca = "!git add --all && git commit";
        s = "status";
      };
      extraConfig = {
        safe.directory = "/etc/nixos/";
        init.defaultBranch = "main";
        core.editor = "nvim";
      };
    };
    programs.uv = {
      enable = true;
      settings = { python-preference = "only-managed"; };
    };

    # TODO: KDE (help)
    # home.file.".config/kde.org".source = ./kde.org;
    # home.file.".config/kdedefaults".source = ./kdedefaults;
    # home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".source = ./plasma-org.kde.plasma.desktop-appletsrc;

    # TODO: .ssh? (at least config)
  };
}
