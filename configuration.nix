# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
in {
  imports = [
    # https://github.com/NixOS/nixos-hardware/tree/master
    <nixos-hardware/framework/13-inch/7040-amd> # TODO: use a gitignored hardware-specific file for this
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

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  environment.systemPackages = with pkgs; [
    kitty # preferred terminal

    neovim # preferred editor
    ripgrep # better rgrep, used by nvim iirc
    wl-clipboard # wayland clipboard cli, system-level due to use by neovim
    # xclip       # x11 clipboard cli, not needed because programs.xserver.enabled = false

    fish # preferred shell
    eza # better ls, system-level due to fish config replacing ls
    trash-cli # safer rm, system-level so we can use as sudo and due to fish config disabling rm
    zoxide # better cd, system-level due to fish config replacing cd  # TODO: enable from nix, see nix-option programs.zoxide

    gcc # compiler, sometimes useful
    python3
    uv # python, occasionally useful

    git # git

    zip
    unzip # all my homies hate tar.gz

    openvpn

    networkmanagerapplet
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

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_RUNTIME_DIR = "/run/user/$(id -u)";

    XDG_BIN_HOME = "$HOME/.local/bin";

    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    BOGOFILTER_DIR = "${XDG_DATA_HOME}/bogofilter";
    DOTNET_CLI_HOME = "${XDG_DATA_HOME}/dotnet";
    GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
    GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
    MATHEMATICA_USERBASE = "${XDG_CONFIG_HOME}/mathematica";
    PYTHON_HISTORY = "${XDG_STATE_HOME}/python_history";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
    NODE_REPL_HISTORY = "${XDG_STATE_HOME}/node_repl_history";
    NPM_CONFIG_INIT_MODULE = "${XDG_CONFIG_HOME}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${XDG_CACHE_HOME}/npm";
    NPM_CONFIG_TMP = "${XDG_RUNTIME_DIR}/npm";
    PNPM_HOME = "${XDG_DATA_HOME}/pnpm";

    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";

    PATH = [
      "${XDG_BIN_HOME}"
      "$CARGO_HOME/bin"
      "$HOME/.local/kitty.app/bin"
      "$HOME/.scripts/bin"
      "${PNPM_HOME}"
    ];

    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
  };

  # TODO: make home.file readonly?
  home-manager.users.max = { pkgs, ... }: {

    home = {
      # The state version is required and should stay at the version you
      # originally installed.
      stateVersion = "25.05";
      packages = with pkgs; [
        # hyprland
        waybar
        hyprshot
        brightnessctl
        rofi-wayland

        # languages
        rustup # mutually exclusive with the other rust packages: rust-analyzer, cargo, rustc
        nodejs
        pnpm # trash
        # latexindent # TODO: texlive

        # cli apps
        bat # better cat
        fd # better find
        gh # github cli
        glab # gitlab cli
        fzf # fuzzy-find (idk if necessary for nvim)
        pferd # audi famam

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
      ];

      # Add custom scripts
      file.".scripts".source = ./Scripts;
    };
    xdg = {
      dataFile = {
        # use x86 stable as default
        "rustup/settings.toml".source = ./rustup/settings.toml;
      };
      configFile = {
        # Configure kitty. TODO: This could probably be done here instead
        "kitty".source = ./kitty;

        # Configure nvim. TODO: Probably want to specify a repo or use a submodule instead
        "nvim".source = ./nvim;

        # Configure pferd. TODO: Probably want to specify a repo or use a submodule instead
        "PFERD".source = ./PFERD;
      };
      desktopEntries = {
        hibernate = {
          name = "Hibernate";
          exec = "systemctl hibernate";
          # icon = "hibernate";
          comment = "Hibernate";
          genericName = "Hibernate";
        };
        suspend = {
          name = "Suspend";
          exec = "systemctl suspend-then-hibernate";
          # icon = "suspend";
          comment = "Put System to Sleep";
          genericName = "Put System to Sleep";
        };
        shutdown = {
          name = "Shut Down";
          exec = "shutdown -h now";
          # icon = "poweroff";
          comment = "Power off the System";
          genericName = "Power off the System";
        };
        reboot = {
          name = "Reboot";
          exec = "reboot";
          # icon = "restart";
          comment = "Restart the System";
          genericName = "Restart the System";
        };
      };
    };

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
      configFile = ./dunstrc;
    };

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          position = "bottom";
          modules-left = [ "hyprland/workspaces" ];
          modules-right = [
            "tray"
            "power-profiles-daemon"
            "pulseaudio#mic"
            "pulseaudio#out"
            "battery"
            "clock"
            "custom/notification"
          ];

          # TODO: Make this not suck
          "hyprland/workspaces" = {
            format = "{icon}";
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          clock = {
            format = "{:%d/%m  %H:%M}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>
            '';
          };
          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            # format-alt = "{time} {icon}";
            format-icons = [ "" "" "" "" "" ];
          };
          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = ''
              Power profile: {profile}
              Driver: {driver}
            '';
            tooltip = true;
            format-icons = {
              default = "";
              performance = "";
              balanced = "";
              power-saver = "";
            };
          };
          "pulseaudio#mic" = {
            format = "{format_source}";
            format-source = " {volume}%";
            format-source-muted = " {volume}%";
            on-click = "wpctl set-mute @DEFAULT_SOURCE@ toggle";
            on-click-right = "pactl set-source-volume @DEFAULT_SOURCE@ 100%";
            on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
            on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
          };
          "pulseaudio#out" = {
            format = "{icon} {volume}%";
            format-muted = " {volume}%"; # TODO: Mute symbol
            format-bluetooth = "{icon} {volume}%";
            format-bluetooth-muted = " {volume}%"; # TODO: Mute symbol
            format-icons = {
              # headphone = "";
              # hands-free = "";
              # headset = "";
              # phone = "";
              # portable = "";
              # car = "";
              default = [ "" "" "" ];
            };
            on-click = "wpctl set-mute @DEFAULT_SINK@ toggle";
          };
          tray = { spacing = 10; };
        };
      };
      style = builtins.readFile ./waybar/style.css;
    };

    # TODO: https://wiki.nixos.org/wiki/Hyprland config here
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./hyprland.conf;
    };

    # FIXME: Use xdg.configFile

    programs.bash = {
      enable = true;
      bashrcExtra = builtins.readFile ./bash/bashrc-extra;
      historyFile = "$XDG_STATE_HOME/bash/history";
      shellOptions =
        [ "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" ];
      historyControl = [ "ignoreboth" ];
    };

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

    # TODO: KDE (help)
    # home.file.".config/kde.org".source = ./kde.org;
    # home.file.".config/kdedefaults".source = ./kdedefaults;
    # home.file.".config/plasma-org.kde.plasma.desktop-appletsrc".source = ./plasma-org.kde.plasma.desktop-appletsrc;

    # TODO: .ssh? (at least config)
  };
}
