{ ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./interactive.fish;
    shellAliases = {
      rm = "echo 'Use `trash` or `command rm`'";
      c = "clear -x";
      ca = "clear && printf '\\e[3J'";
      mv = "mv -i";
      mkcd = "mkdir $argv && cd";
      uvenv = "source ./.venv/bin/activate.fish";
    };
    shellAbbrs = {
      g = "git";
      py = "uv run python3";
      pypy = "uv run --python=pypy python3";
      gca = "git add -A && git commit";
    };
  };
}
