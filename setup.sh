#!/bin/bash

set -e

mkdir -p -m 700 "$HOME/.ssh"

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
            brew install stow zsh
            ;;
        arch)
            sudo pacman -S --noconfirm stow zsh
            ;;
        ubuntu)
            sudo apt update
            sudo apt install -y stow zsh ncurses-bin
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac

    curl https://mise.run | sh
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

setup_persistent_auth() (
    # Skip machines without an EFS mount configured.
    [[ -n "${EFS_MOUNT_POINT:-}" ]] || return 0

    umask 077
    local auth_root="$EFS_MOUNT_POINT/.cli-auth"
    mkdir -p "$auth_root"
    chmod 700 "$auth_root"

    link_auth() {
        local source="$1" target="$auth_root/$2"
        # Already linked correctly: repeated setup needs no changes.
        if [[ -L "$source" && "$(readlink "$source")" == "$target" ]]; then
            return 0
        fi
        # Refuse to replace another symlink or overwrite either existing copy.
        if [[ -L "$source" || ( -e "$source" && -e "$target" ) ]]; then
            echo "Auth conflict: reconcile $source and $target manually." >&2
            return 1
        fi
        mkdir -p "$(dirname "$source")" "$(dirname "$target")"
        # Preserve existing local credentials by moving them to the shared drive.
        if [[ -e "$source" ]]; then
            mv "$source" "$target"
        fi
        ln -s "$target" "$source"
    }

    # Add one mapping per CLI; keep non-secret configuration local.
    link_auth "${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/auth.json" "pi/auth.json"
)

install_ghostty_terminfo() {
    mkdir -p "$HOME/.terminfo"
    tic -x -o "$HOME/.terminfo" terminfo/xterm-ghostty.src
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
    (cd "$HOME" && crit install pi --force)
}

echo "Installing dependencies..."
install_dependencies

echo "Installing Ghostty terminfo..."
install_ghostty_terminfo

echo "Updating submodules..."
update_submodules

echo "Installing oh-my-zsh and plugins..."
install_oh_my_zsh

echo "Stowing dotfiles..."
stow_dotfiles

echo "Setting up persistent CLI credentials..."
setup_persistent_auth

echo "Configuring zsh as default shell..."
configure_zsh

echo "Installing global tools with mise..."
install_tools

echo "Setup complete! Please restart your shell."
