{
  # FIXME: Some modules here need a fullDesktop conditional.
  # Apply it here somehow?
  imports = [
    ./hypr
    ./auth.nix
    ./kde.nix
    ./misc.nix
    ./qt.nix
    ./shortcuts.nix
    ./misc-apps.nix
  ];
}
