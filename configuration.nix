# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false; # (edited)

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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
    # https://discourse.nixos.org/t/users-users-name-packages-vs-home-manager-packages/22240/3
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # END OF INSTALLER

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  
  hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty         # preferred terminal

    neovim        # preferred editor
    ripgrep       # better rgrep, used by nvim iirc
    wl-clipboard  # wayland clipboard cli, system-level due to use by neovim
    # xclip       # x11 clipboard cli, not needed because programs.xserver.enabled = false

    fish          # preferred shell
    eza           # better ls, system-level due to fish config replacing ls
    trash-cli     # safer rm, system-level so we can use as sudo and due to fish config disabling rm
    zoxide        # better cd, system-level due to fish config replacing cd  # TODO: enable from nix, see nix-option programs.zoxide

    gcc           # compiler, sometimes useful
    python3 uv    # python, occasionally useful

    git           # git

    zip unzip     # all my homies hate tar.gz

    openvpn
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

  # Configure key remaps. Assumes AltGr. key combining with ä on q, ö on p, ü on y.
  # TODO: What about on a british layout?
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

  # Use neovim on a system-level. TODO: Rudimentary config for sudo nvim, e.g. set shiftwidth=2, set expandtab
  programs.neovim = {
     enable = true;
     defaultEditor = true;
  };

  # Steam.
  programs.steam.enable = true;

  # Required to dynamically link executables, such as nvim mason binaries
  programs.nix-ld.enable = true;

  home-manager.useGlobalPkgs = true; # also inherits unfree allowed

  # TODO: make home.file readonly?
  home-manager.users.max = { pkgs, ... }: {

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      # computer languages
      rustup  # mutually exclusive with the other rust packages: rust-analyzer, cargo, rustc
      nodejs pnpm  # trash
      # latexindent # TODO: texlive

      # cli apps
      bat   # better cat
      fd    # better find
      gh    # github cli
      glab  # gitlab cli
      fzf   # fuzzy-find (idk if necessary for nvim)
      pferd # audi famam

      # gui apps
      obs-studio
      gimp
      vscode
      brave
      thunderbird
      gnome-system-monitor
      discord

      # zsh (can't get the plugin packages to work)
      zsh
      zsh-syntax-highlighting
      zsh-autocomplete
      zsh-autosuggestions

      # disk utils
      baobab
      gparted
      
      # pdf
      zathura
      tdf

      # games
      prismlauncher
      lunar-client

    ];

    # FIXME: These should depend directly on the value of XDG_CONFIG_HOME
    
    # Configure kitty. TODO: This could probably be done here instead
    home.file.".config/kitty".source = ./kitty;

    # Configure nvim. TODO: Probably want to specify a repo or use a submodule instead
    home.file.".config/nvim".source = ./nvim;
    # Configure pferd. TODO: Probably want to specify a repo or use a submodule instead
    home.file.".config/PFERD".source = ./PFERD;

    # Add custom scripts
    home.file.".scripts".source = ./Scripts;

    # TODO: https://nixos.wiki/wiki/Environment_variables, to sync with .config here
    home.file.".profile".source = ./dotfiles/.profile;

    # TODO: configure using programs.bash instead
    home.file.".bashrc".source = ./dotfiles/.bashrc;
    home.file.".bash_aliases".source = ./dotfiles/.bash_aliases;
    home.file.".bash_prompt_style".source = ./dotfiles/.bash_prompt_style;
    home.file.".inputrc".source = ./dotfiles/.inputrc;

    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./fish/interactive.fish;
    };
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
      settings = {
        python-downloads = "manual";
        python-preference = "only-managed";
      };
    };

    # Install stable x86 toolchain by default. Can we do this declaratively here instead?
    home.file.".local/share/rustup/settings.toml".source = ./rustup/settings.toml;

    # TODO: KDE (help)
    # home.file.".config/kde.org".source = ./kde.org;
    # home.file.".config/kdedefaults".source = ./kdedefaults;
    # home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".source = ./plasma-org.kde.plasma.desktop-appletsrc;

    # TODO: .ssh? (at least config)
  };
}
