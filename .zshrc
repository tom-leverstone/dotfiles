# --- OH-MY-ZSH ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- ENV VARS ---
export PATH=~/.local/bin:~/bin:$PATH
export EDITOR=vim

# --- KEYBOARD FIXES ---
# Home, End, and Ctrl+Arrows
bindkey "\e[H"    beginning-of-line
bindkey "\e[F"    end-of-line
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
# Backspace/Delete fixes
bindkey "^[[3~"  delete-char
bindkey "^?"      backward-delete-char

# --- MISE ---
# This needs to happen before any calls to tools installed w/ mise
eval "$(mise activate zsh)"

# --- COMPLETION SYSTEM ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     # Case-insensitive
zstyle ':completion:*' menu select                      # Navigable menu

# Generate LS_COLORS from system defaults
if [[ -x /usr/bin/dircolors ]]; then
  eval "$(dircolors -b)"
fi

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colors in menu as ls --color

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# jj dynamic completions
source <(COMPLETE=zsh jj)

# just completions
if command -v just >/dev/null 2>&1; then
    source <(just --completions zsh)
fi

# --- HISTORY SETTINGS ---
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY          # Share history between terminals
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicates
setopt HIST_REDUCE_BLANKS     # Clean up whitespace

# --- SSH AGENT ---
# Requires: sudo pacman -S keychain
if [[ -x /usr/bin/keychain ]]; then
    eval $(keychain --eval --quiet id_rsa)
fi

# --- ALIASES ---
if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
fi
alias ls="ls --color=auto"
