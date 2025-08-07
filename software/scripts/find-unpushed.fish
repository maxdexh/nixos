set git_repos (
  fd --hidden --fixed-strings --type=directory '.git' / \
    | string match --regex --groups-only '(.*)/\.git/' \
    | sort \
    | uniq \
)

function list_out_of_git
    set -l extra_ignores tmp/ ~/.ssh
    set -l out_of_git (
      fd --hidden --type file {--exclude,$git_repos} {--exclude,$extra_ignores} --color always --full-path --glob "$HOME/**" / \
          | sort \
          | uniq \
    )
    string join \n -- $out_of_git
end

function check_git_repos
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
if contains -- --no-repo $argv
    list_out_of_git $argv
end
if contains -- --unpushed $argv
    check_git_repos $argv
end
