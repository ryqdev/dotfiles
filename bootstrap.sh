#!/bin/bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
REPO_URL="https://github.com/ryqdev/dotfiles"

echo "🚀 Installing dotfiles configuration..."

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
echo "💾 Backup created at: $BACKUP_DIR"
echo ""
echo "🔄 To apply the new configuration:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. For Neovim: just run 'nvim'"
echo ""
echo "📖 For manual installation, use:"
echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/ryqdev/dotfiles/refs/heads/main/bootstrap.sh)\""