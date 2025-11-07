{config, ...}: {
  xdg.configFile."niri/config.kdl".source = config.lib.custom.mkNixConfigSymlink ./config.kdl;
}
