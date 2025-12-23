#!/bin/bash

set -e

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files and directories to exclude from copying
EXCLUDE_LIST=(
    ".git"
    "README.md"
    "setup.sh"
)

# Copy dotfiles to home directory
cd "$SCRIPT_DIR"
for item in .*; do
    # Skip . and ..
    if [ "$item" = "." ] || [ "$item" = ".." ]; then
        continue
    fi

    # Check if item is in exclude list
    skip=false
    for exclude in "${EXCLUDE_LIST[@]}"; do
        if [ "$item" = "$exclude" ]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = false ]; then
        cp -r "$SCRIPT_DIR/$item" "$HOME/"
    fi
done

# Set shell to zsh
sudo chsh -s $(which zsh) $(whoami)

# Install git-delta
if ! command -v delta &> /dev/null; then
    wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
    sudo dpkg -i git-delta_0.18.2_amd64.deb
    rm git-delta_0.18.2_amd64.deb
fi

# Install Claude Code
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
fi

# Install uv
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Install llm
if ! command -v llm &> /dev/null; then
    uv tool install llm
fi

# Install llm-anthropic plugin
llm install llm-anthropic

# Install jj
if ! command -v jj &> /dev/null; then
    wget https://github.com/jj-vcs/jj/releases/download/v0.36.0/jj-v0.36.0-x86_64-unknown-linux-musl.tar.gz
    tar -xvf jj-v0.36.0-x86_64-unknown-linux-musl.tar.gz
    sudo mv jj /usr/local/bin/
fi

# Install starship prompt
# -s -- -y to pass -y to the script for non-interactive use
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install zsh plugins
sudo apt install zsh-syntax-highlighting
sudo apt install zsh-autosuggestions
