if [ "$(cat /proc/$PPID/comm)" = 'kitty' ]; then
  alias clear='printf "\E[H\E[3J"'
fi

# opens kitty and close current terminal
alias termswap='kittysc && exit'

# initialize zoxide to shadow cd and define cdi (interactive)
eval "$(zoxide init bash --cmd cd)"
