{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty # preferred terminal

    wl-clipboard # wayland clipboard cli, used by neovim
    # xclip

    fish # preferred shell
    trash-cli # safer rm

    gcc # compiler, sometimes useful
    python3
    uv # python, occasionally useful

    git # git

    zip
    unzip # all my homies hate tar.gz

    openvpn
  ];

  # Use neovim on a system-level.
  # TODO: Rudimentary config for sudo nvim, e.g. set shiftwidth=2, set expandtab
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Steam.
  programs.steam.enable = true;
}
