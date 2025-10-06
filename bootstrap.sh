#!/bin/bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/ryqdev/dotfiles"

echo "🚀 Installing dotfiles configuration..."

# Pre-flight checks for essential tools
check_essential_tools() {
    local missing_tools=()

    if ! command -v git > /dev/null 2>&1; then
        missing_tools+=("git")
    fi

    if ! command -v curl > /dev/null 2>&1; then
        missing_tools+=("curl")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "❌ Essential tools missing: ${missing_tools[*]}"
        echo ""
        echo "🔧 Please install the missing tools first:"
        local os=$(detect_os)
        case $os in
            "apt")
                echo "💡 For Ubuntu/Debian, run:"
                echo "   sudo apt-get update"
                echo "   sudo apt-get install -y git curl"
                ;;
            "yum")
                echo "💡 For CentOS/RHEL, run:"
                echo "   sudo yum install -y git curl"
                ;;
            "dnf")
                echo "💡 For Fedora, run:"
                echo "   sudo dnf install -y git curl"
                ;;
            "pacman")
                echo "💡 For Arch Linux, run:"
                echo "   sudo pacman -S --noconfirm git curl"
                ;;
            "zypper")
                echo "💡 For openSUSE, run:"
                echo "   sudo zypper install -y git curl"
                ;;
            "macos")
                echo "💡 For macOS, run:"
                echo "   brew install git curl"
                echo "   # Or install Xcode Command Line Tools: xcode-select --install"
                ;;
        esac
        echo ""
        echo "After installing the missing tools, run this script again."
        exit 1
    fi

    echo "✅ Essential tools check passed"
}

# Function to detect OS and package manager
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "apt"
        elif command -v yum &> /dev/null; then
            echo "yum"
        elif command -v dnf &> /dev/null; then
            echo "dnf"
        elif command -v pacman &> /dev/null; then
            echo "pacman"
        elif command -v zypper &> /dev/null; then
            echo "zypper"
        else
            echo "unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to install packages
install_packages() {
    local os=$(detect_os)
    local essential_packages=("git" "curl" "zsh")
    local additional_packages=("fzf" "neovim" "tmux" "autojump")

    echo "📦 Detected OS: $os"
    echo "🔧 Installing essential packages: ${essential_packages[*]}"

    case $os in
        "apt")
            echo "📋 Ubuntu/Debian detected. Checking available packages..."
            echo "💡 To install packages manually, run:"
            echo "   sudo apt-get update"
            echo "   sudo apt-get install -y ${essential_packages[*]} ${additional_packages[*]}"
            # Check if packages are available without sudo
            if command -v git > /dev/null 2>&1; then
                echo "✅ git is already installed"
            else
                echo "⚠️  git is not installed (manual installation required)"
            fi
            if command -v zsh > /dev/null 2>&1; then
                echo "✅ zsh is already installed"
            else
                echo "⚠️  zsh is not installed (manual installation required)"
            fi
            if command -v curl > /dev/null 2>&1; then
                echo "✅ curl is already installed"
            else
                echo "⚠️  curl is not installed (manual installation required)"
            fi
            ;;
        "yum")
            echo "📋 CentOS/RHEL detected. Checking available packages..."
            echo "💡 To install packages manually, run:"
            echo "   sudo yum install -y ${essential_packages[*]} ${additional_packages[*]}"
            check_packages_available "${essential_packages[@]}"
            ;;
        "dnf")
            echo "📋 Fedora detected. Checking available packages..."
            echo "💡 To install packages manually, run:"
            echo "   sudo dnf install -y ${essential_packages[*]} ${additional_packages[*]}"
            check_packages_available "${essential_packages[@]}"
            ;;
        "pacman")
            echo "📋 Arch Linux detected. Checking available packages..."
            echo "💡 To install packages manually, run:"
            echo "   sudo pacman -S --noconfirm ${essential_packages[*]} ${additional_packages[*]}"
            check_packages_available "${essential_packages[@]}"
            ;;
        "zypper")
            echo "📋 openSUSE detected. Checking available packages..."
            echo "💡 To install packages manually, run:"
            echo "   sudo zypper install -y ${essential_packages[*]} ${additional_packages[*]}"
            check_packages_available "${essential_packages[@]}"
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install "${essential_packages[@]}"
                brew install "${additional_packages[@]}"
            else
                echo "⚠️  Homebrew not found. Please install Homebrew first:"
                echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                echo "    Then run this script again."
                exit 1
            fi
            ;;
        *)
            echo "⚠️  Unknown package manager. Please install manually:"
            echo "   Essential: ${essential_packages[*]}"
            echo "   Additional: ${additional_packages[*]}"
            echo "   Then run this script again."
            exit 1
            ;;
    esac
}

# Function to check if packages are available (without sudo)
check_packages_available() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if command -v "$package" > /dev/null 2>&1; then
            echo "✅ $package is already installed"
        else
            echo "⚠️  $package is not installed (manual installation required)"
        fi
    done
}

# Function to check C compilers for Neovim (without sudo)
check_c_compilers() {
    local os=$(detect_os)

    echo "🔧 Checking C compilers for Neovim compilation..."

    # Check if any C compiler is available
    if command -v gcc > /dev/null 2>&1; then
        echo "✅ gcc is available"
    elif command -v clang > /dev/null 2>&1; then
        echo "✅ clang is available"
    elif command -v cc > /dev/null 2>&1; then
        echo "✅ cc is available"
    else
        echo "⚠️  No C compiler found (gcc/clang required for Neovim)"
        echo "💡 To install C compilers manually:"
        case $os in
            "apt")
                echo "   sudo apt-get install -y build-essential gcc clang make"
                ;;
            "yum")
                echo "   sudo yum groupinstall -y 'Development Tools'"
                echo "   sudo yum install -y gcc clang"
                ;;
            "dnf")
                echo "   sudo dnf groupinstall -y 'Development Tools'"
                echo "   sudo dnf install -y gcc clang"
                ;;
            "pacman")
                echo "   sudo pacman -S --noconfirm base-devel gcc clang"
                ;;
            "zypper")
                echo "   sudo zypper install -y -t pattern devel_basis"
                echo "   sudo zypper install -y gcc clang"
                ;;
            "macos")
                echo "   xcode-select --install"
                ;;
        esac
    fi
}

# Function to check zsh as default shell (without sudo)
check_zsh_default() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "🐚 Current shell: $SHELL"
        echo "💡 To set zsh as default shell manually, run:"
        echo "   chsh -s \$(which zsh)"
        echo "   # or: sudo usermod -s \$(which zsh) \$USER"
        echo "   Then restart your terminal"
    else
        echo "✅ zsh is already the default shell"
    fi
}

# Function to install additional tools based on detected configurations
install_additional_tools() {
    local os=$(detect_os)

    echo "🔍 Checking for additional tool requirements..."

    # Check C compilers first (needed for Neovim)
    check_c_compilers

    # Check if LazyVim configuration exists and install required tools
    if [ -d "$DOTFILES_DIR/.config/lazyvim" ]; then
        echo "📦 LazyVim configuration detected, installing dependencies..."
        case $os in
            "apt")
                sudo apt-get install -y ripgrep fd-find || true
                ;;
            "yum"|"dnf")
                sudo yum install -y ripgrep fd-find || true
                ;;
            "pacman")
                sudo pacman -S --noconfirm ripgrep fd || true
                ;;
            "macos")
                brew install ripgrep fd || true
                ;;
        esac
    fi

    # Check if Powerlevel10k theme is used and install required fonts
    if [ -f "$DOTFILES_DIR/.p10k.zsh" ]; then
        echo "🎨 Powerlevel10k theme detected, installing recommended fonts..."
        case $os in
            "apt")
                sudo apt-get install -y fonts-powerline || true
                ;;
            "yum"|"dnf")
                sudo yum install -y powerline-fonts || true
                ;;
            "pacman")
                sudo pacman -S --noconfirm powerline-fonts || true
                ;;
            "macos")
                brew tap homebrew/cask-fonts
                brew install --cask font-meslo-lg-nerd-font || true
                ;;
        esac
    fi

    # Check lazygit availability
    if ! command -v lazygit > /dev/null 2>&1; then
        echo "📦 lazygit is not installed"
        echo "💡 To install lazygit manually:"
        case $os in
            "apt")
                echo "   sudo apt-get install -y lazygit"
                echo "   # If not available: download from https://github.com/jesseduffield/lazygit/releases"
                ;;
            "yum"|"dnf")
                echo "   sudo yum install -y lazygit"
                echo "   # If not available: download from https://github.com/jesseduffield/lazygit/releases"
                ;;
            "pacman")
                echo "   sudo pacman -S --noconfirm lazygit"
                ;;
            "macos")
                echo "   brew install lazygit"
                echo "   # Or download from https://github.com/jesseduffield/lazygit/releases"
                ;;
            *)
                echo "   Download from: https://github.com/jesseduffield/lazygit/releases"
                ;;
        esac
    else
        echo "✅ lazygit is available"
    fi

    # Check zsh as default shell
    check_zsh_default
}

# Run pre-flight checks before main execution
check_essential_tools

# Install essential packages
install_packages

# Install additional tools based on configuration
install_additional_tools

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Clone or update dotfiles repository
if [ -d "$DOTFILES_DIR" ]; then
    echo "📁 Dotfiles directory exists, updating..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo "📥 Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Backup existing configurations
echo "💾 Backing up existing configurations..."
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/" && echo "Backed up .zshrc"
[ -f "$HOME/.zimrc" ] && cp "$HOME/.zimrc" "$BACKUP_DIR/" && echo "Backed up .zimrc"
[ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$BACKUP_DIR/" && echo "Backed up .p10k.zsh"
[ -f "$HOME/.fzf.zsh" ] && cp "$HOME/.fzf.zsh" "$BACKUP_DIR/" && echo "Backed up .fzf.zsh"
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/" && echo "Backed up .gitconfig"
[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/" && echo "Backed up nvim config"

# Install ZSH configurations
echo "⚡ Installing ZSH configurations..."
cp .zshrc "$HOME/"
cp .zimrc "$HOME/"
cp .p10k.zsh "$HOME/"

# Install FZF configuration
echo "🔍 Installing FZF configuration..."
cp fzf.zsh "$HOME/"

# Install Git configuration
echo "📋 Installing Git configuration..."
cp .gitconfig "$HOME/"
[ -f .gitconfig.monorepo ] && cp .gitconfig.monorepo "$HOME/"

# Install Neovim configuration
echo "📝 Installing Neovim configuration..."
mkdir -p "$HOME/.config"
if [ -d "$HOME/.config/nvim" ]; then
    rm -rf "$HOME/.config/nvim"
fi
cp -r .config/nvim "$HOME/.config/"

# Install LazyVim configuration (if exists)
if [ -d ".config/lazyvim" ]; then
    echo "📝 Installing LazyVim configuration..."
    if [ -d "$HOME/.config/lazyvim" ]; then
        rm -rf "$HOME/.config/lazyvim"
    fi
    cp -r .config/lazyvim "$HOME/.config/"
fi

# Install LunarVim configuration (if exists)
if [ -d ".config/lunarvim" ]; then
    echo "📝 Installing LunarVim configuration..."
    if [ -d "$HOME/.config/lunarvim" ]; then
        rm -rf "$HOME/.config/lunarvim"
    fi
    cp -r .config/lunarvim "$HOME/.config/"
fi

# Install other configurations
echo "🔧 Installing additional configurations..."

# Install tmux configuration (if exists)
if [ -f ".tmux.conf" ]; then
    cp .tmux.conf "$HOME/"
    echo "Installed tmux configuration"
fi

# Install i3 configuration (if exists)
if [ -d ".config/i3" ]; then
    if [ -d "$HOME/.config/i3" ]; then
        rm -rf "$HOME/.config/i3"
    fi
    cp -r .config/i3 "$HOME/.config/"
    echo "Installed i3 configuration"
fi

# Install i3status configuration (if exists)
if [ -d ".config/i3status" ]; then
    if [ -d "$HOME/.config/i3status" ]; then
        rm -rf "$HOME/.config/i3status"
    fi
    cp -r .config/i3status "$HOME/.config/"
    echo "Installed i3status configuration"
fi

# Install terminator configuration (if exists)
if [ -d ".config/terminator" ]; then
    if [ -d "$HOME/.config/terminator" ]; then
        rm -rf "$HOME/.config/terminator"
    fi
    cp -r .config/terminator "$HOME/.config/"
    echo "Installed terminator configuration"
fi

# Install ghostty configuration (if exists)
if [ -d ".config/ghostty" ]; then
    if [ -d "$HOME/.config/ghostty" ]; then
        rm -rf "$HOME/.config/ghostty"
    fi
    cp -r .config/ghostty "$HOME/.config/"
    echo "Installed ghostty configuration"
fi

# Install Vim configuration (if exists)
if [ -f ".vimrc" ]; then
    cp .vimrc "$HOME/"
    echo "Installed Vim configuration"
fi

# Install SSH configuration (if exists)
if [ -d ".ssh" ]; then
    mkdir -p "$HOME/.ssh"
    cp -r .ssh/* "$HOME/.ssh/"
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh"/*
    echo "Installed SSH configuration"
fi

# Make scripts executable (if scripts directory exists)
if [ -d "scripts" ]; then
    chmod +x scripts/*
    echo "Made scripts executable"
fi

echo ""
echo "✅ Dotfiles installation completed!"
echo ""
echo "📍 Configuration files installed:"
echo "  • ZSH: ~/.zshrc, ~/.zimrc, ~/.p10k.zsh"
echo "  • FZF: ~/.fzf.zsh"
echo "  • Git: ~/.gitconfig"
echo "  • Neovim: ~/.config/nvim"
echo ""
echo "🔧 Tools installed/verified:"
echo "  • Essential: git, curl, zsh"
echo "  • Additional: fzf, neovim, tmux, autojump"
echo "  • C Compilers: gcc, clang, build-essential (for Neovim)"
echo "  • Optional: lazygit, ripgrep, fd-find, powerline fonts"
echo ""
echo "💾 Backup created at: $BACKUP_DIR"
echo ""
echo "🔄 To complete the setup:"
echo "  1. Install missing packages manually (see instructions above)"
echo "  2. Set zsh as default shell: chsh -s \$(which zsh)"
echo "  3. Restart your terminal"
echo "  4. Run: source ~/.zshrc"
echo "  5. For Neovim: run 'nvim'"
echo "  6. For lazygit: run 'lazygit'"
echo ""
echo "📖 For manual installation, use:"
echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/ryqdev/dotfiles/refs/heads/main/bootstrap.sh)\""