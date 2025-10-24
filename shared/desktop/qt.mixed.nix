{G, ...}: {
  # NOTE: Do not bother with qtct/qt5ct/qt6ct, set everything to "kde6" and use the
  # plasma system settings (plasma not required) to configure the theme.
  # If breeze cursors are grey you are using KDE 5 systemsettings!
  qt = {
    enable = true;
    platformTheme = G.ctx.pick {
      home = {name = "kde6";};
      system = "kde6";
    };
  };
  # systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = "kde";
}
