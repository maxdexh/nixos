{
  pkgs,
  G,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    (writeShellScriptBin "nvim-unstable" "exec -a $0 ${G.pkgs-unstable.neovim}/bin/nvim $@")
  ];
}
