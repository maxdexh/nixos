{
  lib,
  ctx,
  ...
}:
{
  # NOTE: Do not bother with qtct/qt5ct/qt6ct, set everything to "kde" and use the
  # plasma system settings (plasma not required) to configure the theme.
  config = lib.mkMerge [
    (ctx.os.set {
      qt.enable = true;
      qt.platformTheme = "kde";
    })
    (ctx.hm.set {
      qt.enable = true;
      qt.platformTheme.name = "kde";
    })
  ];
}
