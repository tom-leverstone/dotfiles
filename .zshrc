# --- ENV VARS ---
export PATH=~/.local/bin:$PATH
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

# --- COMPLETION SYSTEM ---
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     # Case-insensitive
zstyle ':completion:*' menu select                      # Navigable menu

# Generate LS_COLORS from system defaults
if [[ -x /usr/bin/dircolors ]]; then
  eval "$(dircolors -b)"
fi

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colors in menu as ls --color

# jj dynamic completions
source <(COMPLETE=zsh jj)

# just completions
source <(just --completions zsh)

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

# --- STARSHIP PROMPT ---
eval "$(starship init zsh)"

# --- PLUGINS ---
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- ALIASES ---
if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
fi
alias ls="ls --color=auto"
