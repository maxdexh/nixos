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

  parts.nix-settings = {
    tags = ["personal"];
    nixosOrHm = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        use-xdg-base-directories = true;
      };
    };
  };
}
