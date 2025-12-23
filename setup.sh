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
    stow --target="$HOME" --ignore='.git' --ignore='README.md' --ignore='setup.sh' .
}

configure_zsh() {
    sudo chsh -s $(which zsh) $(whoami)
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
}

install_tools() {
    mise install --yes

    # For tools that relies on mise
    uv tool install llm
    llm install llm-anthropic
}

echo "Installing dependencies..."
install_dependencies

echo "Stowing dotfiles..."
stow_dotfiles

echo "Configuring zsh as default shell..."
configure_zsh

echo "Installing global tools with mise..."
install_tools

echo "Setup complete! Please restart your shell."
