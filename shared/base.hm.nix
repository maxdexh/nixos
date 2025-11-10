{config, ...}: {
  xdg.configFile."home-manager".source =
    config.lib.file.mkOutOfStoreSymlink config.custom.host.nixConfigLocation;
}
