{
  defaultTags.default = true;

  parts.base = {
    tags = ["default"];
    nixos.imports = [./base-os.nix];
  };
}
