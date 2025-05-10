#!/usr/bin/env bash
set -euo pipefail
set -x  # Enable debugging (comment out if too verbose)

################################################################################
# 1. Detect Linux Distro (for package installation commands)
################################################################################
if [ -f /etc/debian_version ]; then
    DISTRO="DEBIAN"
elif [ -f /etc/arch-release ]; then
    DISTRO="ARCH"
else
    echo "Unsupported or unrecognized Linux distribution."
    exit 1
fi

################################################################################
# 2. Ensure Zsh is installed
################################################################################
if ! command -v zsh >/dev/null 2>&1; then
    echo "Zsh not found. Installing Zsh..."
    if [ "$DISTRO" = "DEBIAN" ]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif [ "$DISTRO" = "ARCH" ]; then
        sudo pacman -Sy --noconfirm
        sudo pacman -S --noconfirm zsh
    fi
else
    echo "Zsh is already installed."
fi

################################################################################
# 3. If not running under Zsh, change shell (if needed) and re-run this script
################################################################################
if [ -z "${ZSH_VERSION:-}" ]; then
    CURRENT_SHELL="$(basename "$SHELL")"

    # Only switch if the current shell isn't Zsh
    if [ "$CURRENT_SHELL" != "zsh" ]; then
        echo "Changing default shell to Zsh..."
        if sudo chsh -s "$(command -v zsh)" $USER 2>/dev/null; then
            echo "Successfully changed shell to Zsh. Re-running script under Zsh..."
        else
            echo "WARNING: Could not change default shell automatically (lack of permissions?)."
            echo "Attempting to proceed by manually starting a Zsh subshell..."
        fi
    fi

    # Re-run this script under Zsh (passing all arguments)
    exec zsh "$0" "$@"
fi

################################################################################
# 4. Now we are in a Zsh session. Proceed with the rest.
################################################################################
echo "Confirmed we are running under Zsh..."

################################################################################
# 5. Install system packages (Git, Curl, Wget, Htop, etc.)
################################################################################
if [ "$DISTRO" = "DEBIAN" ]; then
    sudo apt-get update
    sudo apt-get install -y git curl wget htop
elif [ "$DISTRO" = "ARCH" ]; then
    sudo pacman -Sy --noconfirm
    sudo pacman -S --noconfirm zsh git curl wget htop
fi

################################################################################
# 6. Install Rust (if not already)
################################################################################
echo "Checking for Rust..."
if ! command -v rustc >/dev/null 2>&1; then
    echo "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source Rust environment
    source "$HOME/.cargo/env"
else
    echo "Rust is already installed. Skipping..."
fi

################################################################################
# 7. Install Oh My Zsh (if not installed)
################################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh (unattended)..."
    # The installer normally tries to switch you into Zsh, but we're already here,
    # so we can do it unattended.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
       "" --unattended
else
    echo "Oh My Zsh already installed. Skipping..."
fi

################################################################################
# 8. Install zsh-autosuggestions
################################################################################
if [ ! -d "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions already exists. Skipping..."
fi

################################################################################
# 9. Install zsh-syntax-highlighting
################################################################################
if [ ! -d "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already exists. Skipping..."
fi

################################################################################
# 10. Install powerlevel10k theme
################################################################################
if [ ! -d "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/themes/powerlevel10k" ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/themes/powerlevel10k"
else
    echo "powerlevel10k already exists. Skipping..."
fi

################################################################################
# 10. Install lazygit (if not installed)
################################################################################
if ! command -v lazygit >/dev/null 2>&1; then
    echo "Installing lazygit..."
    if [ "$DISTRO" = "DEBIAN" ]; then
        LAZYGIT_VERSION="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
            | grep -Po '"tag_name": "v\K[^"]*')"
        curl -Lo lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit.tar.gz lazygit
    elif [ "$DISTRO" = "ARCH" ]; then
        sudo pacman -S --noconfirm lazygit
    fi
else
    echo "lazygit is already installed. Skipping..."
fi

################################################################################
# 11. Setting up dotfiles
################################################################################
echo "Linking dotfiles..."

# Remove existing files if they exist
[ -f "$HOME/.zshrc" ] && rm -f "$HOME/.zshrc"
[ -f "$HOME/.gitconfig" ] && rm -f "$HOME/.gitconfig"

# If in GitHub Codespaces:
if [ -d /workspaces/.codespaces/.persistedshare/dotfiles ]; then
    ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.zshrc     "$HOME/.zshrc"
    ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.p10k.zsh  "$HOME/.p10k.zsh"
    ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.gitconfig "$HOME/.gitconfig"

else
    # For everything else, assume .zshrc and .gitconfig are in the current directory
    ln -s "$(pwd)/.zshrc"      "$HOME/.zshrc"
    ln -s "$(pwd)/.gitconfig"  "$HOME/.gitconfig"
fi

################################################################################
# 12. Install Lazyvim
################################################################################
sudo apt install neovim -y
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

################################################################################
echo "Setup complete! Your shell is now Zsh."
################################################################################
