#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Detect OS and package manager
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        log_error "Cannot detect OS version"
        exit 1
    fi

    case $OS in
        ubuntu|debian)
            PKG_MANAGER="apt-get"
            UPDATE_CMD="$PKG_MANAGER update"
            INSTALL_CMD="$PKG_MANAGER install -y"
            ;;
        fedora)
            PKG_MANAGER="dnf"
            UPDATE_CMD="$PKG_MANAGER update -y"
            INSTALL_CMD="$PKG_MANAGER install -y"
            ;;
        arch|manjaro)
            PKG_MANAGER="pacman"
            UPDATE_CMD="$PKG_MANAGER -Sy"
            INSTALL_CMD="$PKG_MANAGER -S --noconfirm"
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    log_info "Detected OS: $OS $VER"
}

# Update system
update_system() {
    log_info "Updating system packages..."
    $UPDATE_CMD
    log_success "System updated"
}

# Install essential packages
install_essentials() {
    log_info "Installing essential packages..."

    case $OS in
        ubuntu|debian)
            $INSTALL_CMD curl wget git zsh build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release
            ;;
        fedora)
            $INSTALL_CMD curl wget git zsh gcc gcc-c++ kernel-devel kernel-headers dnf-plugins-core
            ;;
        arch|manjaro)
            $INSTALL_CMD curl wget git zsh base-devel
            ;;
    esac

    log_success "Essential packages installed"
}

# Install additional tools
install_tools() {
    log_info "Installing additional tools..."

    case $OS in
        ubuntu|debian)
            # Install fzf
            $INSTALL_CMD fzf

            # Install lazygit
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit.tar.gz lazygit

            # Install neovim
            sudo add-apt-repository ppa:neovim-ppa/unstable -y
            $UPDATE_CMD
            $INSTALL_CMD neovim
            ;;
        fedora)
            # Install fzf
            $INSTALL_CMD fzf

            # Install lazygit
            sudo dnf copr enable atim/lazygit -y
            $INSTALL_CMD lazygit

            # Install neovim
            $INSTALL_CMD neovim
            ;;
        arch|manjaro)
            # Install fzf
            $INSTALL_CMD fzf

            # Install lazygit
            $INSTALL_CMD lazygit

            # Install neovim
            $INSTALL_CMD neovim
            ;;
    esac

    log_success "Additional tools installed"
}

# Set up zsh as default shell
setup_zsh() {
    log_info "Setting up zsh..."

    # Install oh-my-zsh if not already installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Set zsh as default shell
    chsh -s $(which zsh)
    log_success "zsh setup complete"
}

# Clone dotfiles repository
clone_dotfiles() {
    log_info "Cloning dotfiles repository..."

    if [[ -d "$HOME/dotfiles" ]]; then
        log_warning "dotfiles directory already exists, removing..."
        rm -rf "$HOME/dotfiles"
    fi

    git clone https://github.com/ryqdev/dotfiles.git "$HOME/dotfiles"
    log_success "Dotfiles repository cloned"
}

# Create symlinks for dotfiles
setup_symlinks() {
    log_info "Setting up dotfiles symlinks..."

    local dotfiles_dir="$HOME/dotfiles"

    # Backup existing files
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d_%H%M%S)"
    [[ -d "$HOME/.config/nvim" ]] && cp -r "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"

    # Create symlinks
    ln -sf "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
    ln -sf "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"

    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Link nvim config
    if [[ -d "$dotfiles_dir/.config/nvim" ]]; then
        ln -sf "$dotfiles_dir/.config/nvim" "$HOME/.config/nvim"
    fi

    log_success "Dotfiles symlinks created"
}

# Install nvim plugins
setup_nvim() {
    log_info "Setting up neovim..."

    # Check if nvim config exists
    if [[ -d "$HOME/.config/nvim" ]]; then
        log_info "Installing nvim plugins..."

        # Install packer.nvim if not already installed
        if [[ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]]; then
            git clone --depth 1 https://github.com/wbthomason/packer.nvim \
                "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
        fi

        # Run PackerSync to install plugins
        nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

        log_success "Neovim setup complete"
    else
        log_warning "No nvim config found, skipping plugin installation"
    fi
}

# Main installation function
main() {
    log_info "Starting bootstrap installation..."

    check_root
    detect_os
    update_system
    install_essentials
    install_tools
    clone_dotfiles
    setup_symlinks
    setup_zsh
    setup_nvim

    log_success "Bootstrap installation complete!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to reload your configuration"
    log_info "You may need to log out and back in for the shell change to take effect"
}

# Run main function
main "$@"