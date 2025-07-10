set fish_greeting

if string match -q '*kitty' $TERM
    # overrides clear to also clear the terminal buffer in kitty
    # fish printf just prints the escapes as-is
    function clear -d "Clear alias for kitty, including scrollback buffer"
        printf "\e[H\e[3J"
    end
    bind ctrl-l clear repaint
end
function list-fonts -d "List installed fonts"
    fc-list | sed 's/.*:\\s*\\([^:]*\\):.*/\\1/' | tr ',' '\\n' | sed 's/^[ \\t]*//;s/[ \\t]*$//' | sort | uniq
end
function mkcd -d "Create directory and cd" -a path
    mkdir $path
    cd $path
end

bind ctrl-c cancel-commandline

# allows seting the clipboard using `... | setclip`
alias setclip='xclip -sel c'

# uses eza instead of ls. TODO: configure
alias ls='eza'

# trash is still suboptimal due to working slightly differently :/
alias rm='echo "rm is disabled, use trash or /bin/rm instead."'

# TODO: This still deletes overwritten files, a trashing variant would be better
alias mv='mv -i'

alias gittree='git log --graph --pretty=oneline --abbrev-commit --all'
# TODO: safer versions of mv, cp

# initialize zoxide to shadow cd and define cdi (interactive)
zoxide init fish --cmd cd | source

alias c=clear
alias j=cd
alias g=git
alias rgrep=rg

alias python3='uv run python3'
function uvenv
    pushd .
    source ./.venv/bin/activate.fish
    popd
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n (prompt_login)
    echo -n ':'
    set_color $color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n (fish_vcs_prompt)
    set_color normal
    echo -n ' '
    echo -n $prompt_status
    echo
    echo -n $suffix
    echo -n ' '
end
function fish_right_prompt
    set -l d (set_color brgrey)(date "+%R")(set_color normal)

    set -l duration "$cmd_duration$CMD_DURATION"
    if test $duration -gt 100
        set duration (math $duration / 1000)s
    else
        set duration
    end

    set -q VIRTUAL_ENV_DISABLE_PROMPT
    or set -g VIRTUAL_ENV_DISABLE_PROMPT true
    set -q VIRTUAL_ENV
    and set -l venv (string replace -r '.*/' '' -- "$VIRTUAL_ENV")

    set_color normal
    string join " " -- $venv $duration $d
end
