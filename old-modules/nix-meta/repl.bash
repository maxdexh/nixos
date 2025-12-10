set -e
set -o pipefail
shopt -s inherit_errexit

showSyntax() {
	echo "$0 {hm | os} [--flake flake-uri]"
	exit 1
}

# Parse args
action=

while [ "$#" -gt 0 ]; do
	i="$1"
	shift 1
	case "$i" in
	--help)
		showSyntax
		;;
	hm | os)
		# exactly one action mandatory, bail out if multiple are given
		if [ -n "$action" ]; then showSyntax; fi
		action="$i"
		;;
	--flake)
		if [ -z "$1" ]; then
			log "$0: '$i' requires an argument"
			exit 1
		fi
		flake="$1"
		shift 1
		;;
	*)
		log "$0: unknown option \`$i'"
		exit 1
		;;
	esac
done

hostname="$(cat /proc/sys/kernel/hostname)"

if [ "$action" = hm ]; then
	flakeAttrBase='homeConfigurations'
	flakeAttrDefault="$USER@$hostname"
	argsBase='{}'
elif [ "$action" = os ]; then
	flakeAttrBase='nixosConfigurations'
	flakeAttrDefault="$hostname"
	argsBase='configuration._module.args // configuration._module.specialArgs'
else
	echo "$0: Unknown action $action"
fi

if [ -z "$action" ]; then showSyntax; fi

# For convenience, use the hostname as the default configuration to
# build from the flake.
if [[ -n $flake ]]; then
	# parse out flake and attr
	if [[ $flake =~ ^(.*)\#([^\#\"]*)$ ]]; then
		flake="${BASH_REMATCH[1]}"
		flakeAttr="${BASH_REMATCH[2]}"
	else
		echo "$0: Malformed flake $flake"
		exit 1
	fi
fi

if [[ -z $flake ]]; then
	flake="$NIXOS_FLAKE"
	if [[ -z $flake ]]; then
		echo "$0: Failed to determine flake location"
		exit 1
	fi
fi

if [[ -z $flakeAttr ]]; then
	flakeAttr="$flakeAttrDefault"
fi
flakeAttr="$flakeAttrBase.\"$flakeAttr\""

d='$'
q='"'
bold="$(echo -e '\033[1m')"
blue="$(echo -e '\033[34;1m')"
attention="$(echo -e '\033[35;1m')"
reset="$(echo -e '\033[0m')"
if [[ -e $flake ]]; then
	flakePath=$(realpath "$flake")
else
	flakePath=$flake
fi

exec nix repl --expr "
  let
    flake = builtins.getFlake ''$flakePath'';
    configuration = flake.$flakeAttr;
    motd = ''Loading $flakeAttr in $flake'';
    scope = ($argsBase) // {
      inherit (configuration) config options pkgs;
      lib = configuration.lib or configuration.pkgs.lib;
      inherit flake;
    };
  in
    builtins.seq scope
    builtins.seq scope.config
    builtins.trace motd
    scope
"
