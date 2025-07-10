# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/$(id -u)" || true

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export BOGOFILTER_DIR="$XDG_DATA_HOME/bogofilter"
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export MATHEMATICA_USERBASE="$XDG_CONFIG_HOME"/mathematica
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
export PYTHON_HISTORY="$XDG_STATE_HOME"/python_history
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || true
PATH="$CARGO_HOME/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.local/kitty.app/bin:$PATH"
PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
PATH="$HOME/.scripts/bin:$PATH"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/* || true

export VISUAL=nvim
export EDITOR="$VISUAL"
export MANPAGER="nvim +Man!"

# pnpm
export PNPM_HOME="/home/max/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
