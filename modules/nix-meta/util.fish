set -g filename "$(status filename)"

function full-usage
    hm-command --help
    os-command --help
    fetch-programs-sql --help
end

argparse --stop-nonopt h/help -- $argv || begin
    full-usage
    exit 1
end
set -q _flag_help && begin
    full-usage
    exit 0
end

function hm-command
end

function os-command
end

function fetch-programs-sql
end

set -l subcommand $argv[1]
set -e argv[1]
switch $subcommand
    case hm
        hm-command $argv
    case os
        os-command $argv
    case fetch-programs-sql
        fetch-programs-sql
end
