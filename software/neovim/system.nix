{pkgs, ...}: {
  # TODO: Rudimentary config for sudo nvim, e.g. set shiftwidth=2, set expandtab
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [wl-clipboard];
}
