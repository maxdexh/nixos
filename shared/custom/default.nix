{
  config,
  lib,
  ...
}: {
  imports = [
    ./hm-env-vars.nix
    ./host-options.nix
  ];

  config._module.args.custom = config.custom;
  options.custom.lib = lib.mkOption {
    type = lib.types.anything;
    default = {};
  };
}
