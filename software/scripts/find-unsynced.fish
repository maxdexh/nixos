set -g cmd_name "$(status filename)"
set cmd_name "$(basename $cmd_name)"

function print-usage -a exit_status
    set -l remember_status $status
    set -q exit_status[1] || set exit_status $remember_status

    set -l usage --help 'unpushed [--help]' 'no-repo [--help]'
    set usage "$cmd_name "$usage
    set usage "$(string join \n -- Usage: $usage)"

    if test 0 -eq $exit_status
        echo $usage
    else
        echo $usage >&2
    end
    exit $exit_status
end

set -g commands

set -a commands no-repo
function no-repo
    set -l extra_ignores ~/.ssh/ ~/tmp/ ~/Pictures/Screenshots/ ~/Downloads/
    fd --hidden --type file {--exclude,$git_repos} {--exclude,$extra_ignores} --color always --full-path --glob ~/'**' / \
        | sort \
        | uniq
end

set -a commands unpushed
function unpushed
    for repo in $git_repos
        cd $repo

        set -l gstatus "$(git -c color.ui=always status --short)"
        set -l commits "$(git -c color.ui=always log --branches --not --remotes --oneline)"

        if test -n "$gstatus" || test -n "$commits"
            echo "$repo has unpushed changes:"
            test -n "$commits" && echo $commits
            test -n "$gstatus" && echo $gstatus
            echo
        end
    end
end

set -g usage

function main
    argparse --ignore-unknown --name $cmd_name h/help -- $argv || print-usage
    set -ql _flag_help && print-usage
    set -q argv[1] || print-usage 0

    set -g git_repos (
        fd --hidden --fixed-strings --type=directory '.git' / \
            | string match --regex --groups-only '(.*)/\.git/' \
            | sort \
            | uniq \
    )
    $argv
end

main $argv
