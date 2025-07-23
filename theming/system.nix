{ pkgs, ... }:

{
  qt = {
    enable = true;
    style = "breeze";
    platformTheme = "kde6";
  };

  fonts.packages = with pkgs; [
    # cascadia-code
    nerd-fonts.caskaydia-mono
    font-awesome
    nerd-fonts.jetbrains-mono
  ];
}
