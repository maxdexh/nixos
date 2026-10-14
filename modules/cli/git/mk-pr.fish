function print_help -a exit_code
    echo '\
USAGE:
  mk-pr [FLAGS] [-- TOOL_FLAGS]

FLAGS:
  -h, --help            Displays this message.
  -d, --defaults        Sets the other flags using presets
  -t, --tool            The tool to use. Currently only accepts `gh`
  -r, --repo            The repo to create a PR on.
  -o, --origin          The remote to push to.
  -b, --branch          The the branch to push. Defaults to the current branch. Same behavior as `git push`
'
    exit $exit_code
end

argparse h/help 'd/defaults=?' 't/tool=?' 'r/repo=?' 'o/origin=?' 'b/branch=?' -- $argv || print_help 1

if set -q _flag_help
    print_help 0
end

switch $_flag_defaults
    case rust
        set -q _flag_repo || set _flag_repo rust-lang/rust
        set -q _flag_tool || set _flag_tool gh
    case ''
    case '*'
        echo "Unknown preset $_flag_defaults"
        exit 1
end

set -q _flag_origin || set _flag_origin origin
set -q _flag_branch || set _flag_branch -- "$(git rev-parse --abbrev-ref HEAD)" # Could be detached, but whatever

switch $_flag_tool
    case gh
        git push -u --repo "$_flag_origin" "$_flag_branch"
        exec gh pr create --repo "$_flag_repo" $argv
    case '*'
        echo "Unknown tool '$_flag_tool'"
        exit 1
end
