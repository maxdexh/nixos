set fish_greeting

bind ctrl-c cancel-commandline

if set -q NVIM
    fish_default_key_bindings
else
    fish_vi_key_bindings
end

function fish_prompt
    set -l last_pipestatus $pipestatus # pipestatus must be saved right at the start
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

    set -q fish_color_status; or set -g fish_color_status red
    set -l status_color (set_color $fish_color_status)

    printf '%s:%s%s %s\n%s ' \
        (set_color normal; prompt_login) \
        (if fish_is_root_user; set_color $fish_color_cwd_root; else; set_color $fish_color_cwd; end; prompt_pwd) \
        (set_color normal; fish_vcs_prompt) \
        (set_color normal; __fish_print_pipestatus "[" "]" "|" $status_color $status_color $last_pipestatus) \
        (set_color normal; if fish_is_root_user; echo '#'; else; echo '>'; end)
end

function fish_right_prompt
    set_color normal
    string join " " -- \
        (test $CMD_DURATION -gt 100; and echo (math $CMD_DURATION / 1000)s) \
        (set -q VIRTUAL_ENV; and string replace -r '.*/' '' -- "$VIRTUAL_ENV") \
        (set_color brgrey)(date "+%R")(set_color normal)
end
