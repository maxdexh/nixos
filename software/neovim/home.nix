{ ... }:

{
  # TODO: Use a git repo
  xdg.configFile."nvim".source = ./nvim;

  home.sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
}
