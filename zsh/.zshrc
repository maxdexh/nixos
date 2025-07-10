# Lines configured by zsh-newuser-install
HISTFILE=~/.local/state/zsh/history
HISTSIZE=10000
SAVEHIST=100000
setopt autocd extendedglob nomatch
unsetopt beep notify
# End of lines configured by zsh-newuser-install

source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# The following lines were added by compinstall
zstyle :compinstall filename '/home/max/.config/zsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [[ "$TERM" == 'xterm-kitty' ]]; then
  function clear {
    printf '\e[H\e[3J'
  }
  function zle_clear {
    clear
    zle reset-prompt
  }
  zle -N zle_clear
  bindkey "^L" zle_clear
fi

function precmd() {
}

function list-fonts {
  fc-list | sed 's/.*:\\s*\\([^:]*\\):.*/\\1/' | tr ',' '\\n' | sed 's/^[ \\t]*//;s/[ \\t]*$//' | sort | uniq
}

function mkcd {
  mkdir "$1"
  cd $1
}

alias ls=eza
alias rm='echo "rm is disabled, use trash or /bin/rm instead."'
alias mv='mv -i'
alias gittree='git log --graph --pretty=oneline --abbrev-commit --all'
eval "$(zoxide init zsh --cmd cd)"
alias c=clear
alias j=cd
alias g=git
alias python3='uv run python3'
function uvenv {
  source ./.venv/bin/activate
}

bindkey -v # TODO: Configure

autoload -Uz vcs_info
function preexec() {
  prompt_timer="$(date +%s%0N)" # FIXME: this is inaccurate
}
function precmd {
  local ps=("${pipestatus[@]}")
  local now="$(date +%s%0N)"
  if [ $prompt_timer ]; then
    local elapsed="$(($now - $prompt_timer))" # elapsed in nanos
    local elapsed="$(($elapsed / 1000000))"   # elapsed in millis
    if [[ "$elapsed" -ge 10 ]]; then
      local elapsed="$(printf %04d $elapsed)" # elapsed in millis, padded
      prompt_elapsed="${elapsed::-3}.${elapsed: -3}s "
      unset prompt_timer
    fi
    vcs_info
  fi
  if [ "$ps[-1]" -ne 0 ]; then
    prompt_pipe_status=" [$ps[1]$(for pipe in ${ps[@]:1}; do echo -n "|$pipe"; done)]"
  else
    unset prompt_pipe_status
  fi
}

zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST

PROMPT='%F{10}%n%f@%m:%F{2}%~%f${vcs_info_msg_0_}%F{red}${prompt_pipe_status}%f
%% '

ZLE_RPROMPT_INDENT=0
RPROMPT='${prompt_venv}${prompt_elapsed}%F{8}%D{%H:%M}%f' # TODO: venv
