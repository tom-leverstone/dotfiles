#!/bin/bash

set -e

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

install_dependencies() {
    local os=$(detect_os)

    case $os in
        mac)
            brew install mise stow zsh
            ;;
        arch)
            sudo pacman -S --noconfirm mise stow zsh
            ;;
        ubuntu)
            sudo apt update
            sudo apt install -y stow zsh
            curl https://mise.run | sh
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac
}

backup_existing_zshrc() {
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        echo "Found existing .zshrc, backing up to .zshrc-backup-before-toms-dotfile"
        mv "$HOME/.zshrc" "$HOME/.zshrc-backup-before-toms-dotfile"
    fi
}

stow_dotfiles() {
    stow --target="$HOME" \
        --ignore='.git' \
        --ignore='.gitmodules' \
        --ignore='.jj' \
        --ignore='README.md' \
        --ignore='setup.sh' \
        .
}

update_submodules() {
    git submodule update --init --recursive
}

configure_zsh() {
    chsh -s $(which zsh) $(whoami)
}

install_tools() {
    mise install --yes

    # For tools that relies on mise
    uv tool install llm
    llm install llm-anthropic
}

echo "Installing dependencies..."
install_dependencies

echo "Updating submodules..."
update_submodules

echo "Backing up existing .zshrc if present..."
backup_existing_zshrc

echo "Stowing dotfiles..."
stow_dotfiles

echo "Configuring zsh as default shell..."
configure_zsh

echo "Installing global tools with mise..."
install_tools

echo "Setup complete! Please restart your shell."
