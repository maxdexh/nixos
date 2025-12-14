{
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
  ];

  defaultTags.default = true;

  parts.nix-settings = {
    tags = ["default"];
    nixosOrHm = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        use-xdg-base-directories = true;
      };
    };
  };
}
