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
}
