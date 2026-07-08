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

stow_dotfiles() {
    # Files to check for conflicts
    FILES_TO_BACKUP=(".zshrc" ".gitconfig")

    for file in "${FILES_TO_BACKUP[@]}"; do
        TARGET_FILE="$HOME/$file"
        
        # If the file exists (-e) and is NOT a symlink (! -L), back it up
        if [ -e "$TARGET_FILE" ] && [ ! -L "$TARGET_FILE" ]; then
            echo "Backing up existing $TARGET_FILE to $TARGET_FILE.backup..."
            mv "$TARGET_FILE" "$TARGET_FILE.backup"
        fi
    done
    
    stow --target="$HOME" \
        --ignore='.git' \
        --ignore='.gitmodules' \
        --ignore='README.md' \
        --ignore='setup.sh' \
        .
}

update_submodules() {
    git submodule update --init --recursive
}

install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "oh-my-zsh already installed"
    fi
}

configure_zsh() {
    sudo chsh -s $(which zsh) $(whoami)
}

install_tools() {
    mise trust
    mise install --yes
}

echo "Installing dependencies..."
install_dependencies

echo "Updating submodules..."
update_submodules

echo "Installing oh-my-zsh and plugins..."
install_oh_my_zsh

echo "Stowing dotfiles..."
stow_dotfiles

echo "Configuring zsh as default shell..."
configure_zsh

echo "Installing global tools with mise..."
install_tools

echo "Setup complete! Please restart your shell."
