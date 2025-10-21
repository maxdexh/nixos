{...}: {
  # NOTE: Do not bother with qtct/qt5ct/qt6ct, set everything to "kde" and use the
  # plasma system settings (plasma not required) to configure the theme
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };
  systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = "kde";
}
