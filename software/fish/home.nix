{ config, lib, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      bind ctrl-c cancel-commandline
      set -q NVIM && fish_default_key_bindings || fish_vi_key_bindings
    '';
    shellAliases = {
      c = "clear && printf '\\e[3J'";
      mkcd = "mkdir $argv && cd";
      uvenv = "source ./.venv/bin/activate.fish";
    };
    shellAbbrs = {
      py = "uv run python3";
      pypy = "uv run --python=pypy python3";

      mv = "mv -i";

      rm = "trash";

      g = "git";
    } // lib.concatMapAttrs (alias: command: {
      "g${alias}" = if lib.strings.hasPrefix "!" command then
        lib.strings.removePrefix "!" command
      else
        "git ${command}";
    }) config.programs.git.aliases;

    # TODO: Full-clear bind
    functions = {
      fish_prompt = ''
        set -l last_status $status; set -l last_pipestatus $pipestatus

        set -l login "$(set_color normal)$(prompt_login)"
        set -l pwd "$(type -q fish_is_root_user && fish_is_root_user && set_color $fish_color_cwd_root || set_color $fish_color_cwd || set_color green)$(prompt_pwd)"
        set -l pipe "$(set_color $fish_color_status || set_color red)$(test "$last_status" -eq 0 || echo " [$(string join '|' -- $last_pipestatus)]")"
        set -l vcs "$(set_color normal)$(type -q fish_vcs_prompt && fish_vcs_prompt)" # Includes leading space
        set -l suffix "$(set_color normal)$(type -q fish_is_root_user && fish_is_root_user && echo '#' || echo '>')"

        echo -n "$login:$pwd$pipe$vcs"\n"$suffix "
      '';
      fish_right_prompt = ''
        set_color normal
        set -l duration (test $CMD_DURATION -gt 100 && echo (math $CMD_DURATION / 1000)s)
        set -l venv (set -q VIRTUAL_ENV && string replace -r '.*/' "" -- "$VIRTUAL_ENV")
        set -l time "$(set_color brgrey)$(date '+%R')$(set_color normal)"
        string join -n " " -- $venv $duration $time
      '';
    };
  };
}
