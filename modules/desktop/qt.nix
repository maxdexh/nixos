{
  parts.qt = {
    enableIf.tags.desktop = true;

    # NOTE: Do not bother with qtct/qt5ct/qt6ct, set everything to "kde" and use the
    # plasma system settings (plasma not required) to configure the theme.
    hm = {
      qt.enable = true;
      qt.platformTheme.name = "kde";
    };
    nixos = {
      qt.enable = true;
      qt.platformTheme = "kde";
    };
  };
}
