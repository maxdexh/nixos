# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, ... }:

let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";

  find-imports = suffix:
    builtins.filter (lib.strings.hasSuffix suffix) (map toString
      (builtins.filter (p: p != ./default.nix)
        (lib.filesystem.listFilesRecursive ./.)));

  enable-shellint-no-bash = {
    enable = true;
    enableFishIntegration = true;
  };
  enable-shellint = {
    enableBashIntegration = true;
  } // enable-shellint-no-bash;
in {
  imports = [
    # TODO: use a gitignored hardware-specific file for these
    <nixos-hardware/framework/13-inch/7040-amd> # https://github.com/NixOS/nixos-hardware/tree/master
    ./hardware-configuration.nix # Include the results of the hardware scan.

    (import "${home-manager}/nixos")
  ] ++ find-imports "/system.nix";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Required to dynamically link executables, such as nvim mason binaries
  programs.nix-ld.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.max = {
    isNormalUser = true;
    description = "Max";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # TODO: make home.file readonly? 
  home-manager.users.max = { lib, pkgs, ... }: {
    imports = find-imports "/home.nix";

    home = {
      # The state version is required and should stay at the version you
      # originally installed.
      stateVersion = "25.05";
    };
    xdg.dataFile = {
      # use x86 stable as default
      "rustup/settings.toml".source = ./Config/rustup/settings.toml;
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
      configFile = ./Config/dunstrc;
    };

    programs.bash = {
      enable = true;
      bashrcExtra = builtins.readFile ./Config/bashrc-extra;
      historyFile = "$XDG_STATE_HOME/bash/history";
      shellOptions =
        [ "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" ];
      historyControl = [ "ignoreboth" ];
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

    # TODO: .ssh? (at least config)
  };

  # also inherits unfree allowed
  home-manager.useGlobalPkgs = true;

  home-manager.verbose = true;
}
