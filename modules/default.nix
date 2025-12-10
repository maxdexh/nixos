{
  imports = [
    ./nvim/part.nix
    ./nix-meta
  ];

  defaultTags.default = true;

  parts.base = {
    tags = ["default"];
    nixos.imports = [./base-os.nix];
  };

  parts.nixld = {
    tags = ["default"];
    nixos.imports = [./nixld.nix];
  };

  parts.xdg-vars = {
    tags = ["default"];
    hm.imports = [./xdg-vars.nix];
  };
}
