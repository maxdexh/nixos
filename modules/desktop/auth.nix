{
  parts.desktop-auth = {
    enableIf.tags.fullDesktop = true;

    hm = {
      services.hyprpolkitagent.enable = true;
    };
  };
}
