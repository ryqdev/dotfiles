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
            PKG_MANAGER="sudo apt"
            UPDATE_CMD="$PKG_MANAGER update"
            INSTALL_CMD="$PKG_MANAGER install -y"
            ;;
        fedora)
            PKG_MANAGER="sudo dnf"
            UPDATE_CMD="$PKG_MANAGER update -y"
            INSTALL_CMD="$PKG_MANAGER install -y"
            ;;
        arch|manjaro)
            PKG_MANAGER="sudo pacman"
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

            # Install lua dependencies to prevent E970 error
            log_info "Installing lua dependencies for neovim..."
            $INSTALL_CMD lua5.1 liblua5.1-dev luajit libluajit-5.1-dev

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

    # Set zsh as default shell without password prompt
    # Try to use usermod first (requires root), fallback to chsh if needed
    if command -v usermod > /dev/null 2>&1 && [[ $EUID -eq 0 ]]; then
        log_info "Setting zsh as default shell using usermod..."
        usermod -s $(which zsh) $SUDO_USER || log_warning "Failed to set shell with usermod"
    else
        log_info "Setting zsh as default shell using chsh..."
        # Try to change shell without password by modifying /etc/passwd directly (requires root)
        if [[ $EUID -eq 0 ]]; then
            local current_user=$(whoami)
            if [[ $current_user != "root" ]]; then
                current_user=$SUDO_USER
            fi
            sed -i "s|^${current_user}:.*|${current_user}:x:$(id -u):$(id -g):${current_user}:$HOME:$(which zsh)|" /etc/passwd
            log_success "zsh set as default shell for $current_user"
        else
            # If not root, provide instructions for manual shell change
            log_warning "Cannot change shell automatically without root privileges"
            log_info "Please run: chsh -s $(which zsh)"
            log_info "Or log out and back in to use the new shell"
        fi
    fi

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

# Copy dotfiles to home directory
copy_dotfiles() {
    log_info "Copying dotfiles to home directory..."

    local dotfiles_dir="$HOME/dotfiles"

    # Backup existing files
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    [[ -f "$HOME/.zimrc" ]] && cp "$HOME/.zimrc" "$HOME/.zimrc.backup.$(date +%Y%m%d_%H%M%S)"
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d_%H%M%S)"
    [[ -d "$HOME/.config/nvim" ]] && cp -r "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"

    # Copy dotfiles from repository
    if [[ -f "$dotfiles_dir/.zshrc" ]]; then
        cp "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
        log_success "Copied .zshrc"
    else
        log_warning ".zshrc not found in dotfiles repository"
    fi

    if [[ -f "$dotfiles_dir/.zimrc" ]]; then
        cp "$dotfiles_dir/.zimrc" "$HOME/.zimrc"
        log_success "Copied .zimrc"
    else
        log_warning ".zimrc not found in dotfiles repository"
    fi

    if [[ -f "$dotfiles_dir/.gitconfig" ]]; then
        cp "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"
        log_success "Copied .gitconfig"
    else
        log_warning ".gitconfig not found in dotfiles repository"
    fi

    # Create config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Copy nvim config
    if [[ -d "$dotfiles_dir/.config/nvim" ]]; then
        cp -r "$dotfiles_dir/.config/nvim" "$HOME/.config/"
        log_success "Copied nvim configuration"
    else
        log_warning "nvim config not found in dotfiles repository"
    fi

    log_success "Dotfiles copied successfully"
}

# Install nvim plugins
setup_nvim() {
    log_info "Setting up neovim..."

    # Verify neovim installation
    if ! command -v nvim > /dev/null 2>&1; then
        log_error "Neovim not found, skipping nvim setup"
        return 1
    fi

    # Check if nvim can start properly (test for E970 error)
    if ! nvim --headless -c 'lua print("Lua working")' -c 'q' > /dev/null 2>&1; then
        log_error "Neovim lua interpreter error detected (E970)"
        log_info "This may be due to missing lua dependencies or conflicting configurations"
        log_info "Try running: sudo apt-get install --reinstall lua5.1 liblua5.1-dev luajit libluajit-5.1-dev"
        return 1
    fi
}

# Main installation function
main() {
    log_info "Starting bootstrap installation..."

    detect_os
    update_system
    install_essentials
    install_tools
    setup_zsh
    setup_nvim
    clone_dotfiles
    copy_dotfiles

    log_success "Bootstrap installation complete!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to reload your configuration"
    log_info "You may need to log out and back in for the shell change to take effect"
}

# Run main function
main "$@"
