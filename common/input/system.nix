{...}: {
  # Fix palm rejection and disable-while-typing by telling libinput to treat the keyd virtual kb as a builtin keyboard
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
