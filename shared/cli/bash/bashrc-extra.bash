__set_theme() {
	case "$TERM" in
	xterm-color | *-256color | xterm-kitty) color_prompt=yes ;;
	esac

	local RESET user colon directory
	RESET='\[\033[00m\]\[\e[00m\]'

	if [ "$color_prompt" = yes ]; then
		user='\[\033[01;32m\]'
		directory='\[\033[01;34m\]'
	fi

	user+='\u@\h'
	colon+=':'
	directory+='\w'

	if [ "$color_prompt" = yes ]; then
		user+="${RESET}"
		colon+="${RESET}"
		directory+="${RESET}"
	fi

	PS1="${user}${colon}${directory}\n$ "
}
__set_theme

if [ "$(cat /proc/$PPID/comm)" = 'kitty' ]; then
	alias clear='printf "\E[H\E[3J"'
fi
