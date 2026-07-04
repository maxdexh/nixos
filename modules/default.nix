let
  nixSettingsModule = {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
    };
  };
in {
  imports = [
    ./nvim/part.nix
    ./nix-meta
    ./cli
    ./desktop
    ./custom
    ./langs
    ./base-os.nix
    ./nixld.nix
    ./xdg-vars.nix
    ./documentation.nix
  ];

  parts.nix-settings-nixos = {
    enableIf.tags.nixos = true;
    nixos = nixSettingsModule;
  };
  parts.nix-settings-hm = {
    enableIf.tags.nixos = false;
    hm = nixSettingsModule;
  };
}
