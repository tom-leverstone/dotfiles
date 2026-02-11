# --- OH-MY-ZSH ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    ssh-agent
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- ENV VARS ---
export PATH=~/.local/bin:~/bin:$PATH
export EDITOR=vim

# --- MISE ---
# This needs to happen before any calls to tools installed w/ mise
eval "$(mise activate zsh)"

# --- COMPLETIONS ---
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# jj dynamic completions
source <(COMPLETE=zsh jj)

# just completions
if command -v just >/dev/null 2>&1; then
    source <(just --completions zsh)
fi

# --- ALIASES ---
if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
fi
alias ls="ls --color=auto"
