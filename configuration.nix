{ lib, ... }:

let
  find-imports = suffix:
    builtins.filter (lib.strings.hasSuffix suffix) (map toString
      (builtins.filter (p: p != ./default.nix)
        (lib.filesystem.listFilesRecursive ./.)));
in {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.

    <nixos-hardware/framework/13-inch/7040-amd> # https://github.com/NixOS/nixos-hardware/tree/master

    <home-manager/nixos> # https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz
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

  home-manager.users.max = { lib, pkgs, ... }: {
    imports = find-imports "/home.nix";

    xdg.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };

  home-manager = {
    # also inherits unfree allowed
    useGlobalPkgs = true;
    verbose = true;
  };
}
