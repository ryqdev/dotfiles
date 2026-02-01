#!/bin/bash
set -e

# Codespace paths
DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"

echo "==> Updating apt..."
sudo apt update

echo "==> Installing build-essential..."
sudo apt install -y build-essential

echo "==> Installing zsh..."
sudo apt install -y zsh

echo "==> Creating ~/.config directory..."
mkdir -p ~/.config

echo "==> Copying nvim, tmux, and lazygit configs..."
cp -r "$DOTFILES_DIR/.config/nvim" ~/.config/
cp -r "$DOTFILES_DIR/.config/tmux" ~/.config/
cp -r "$DOTFILES_DIR/.config/lazygit" ~/.config/

echo "==> Copying .zshrc and .gitconfig..."
cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
cp "$DOTFILES_DIR/.gitconfig" ~/.gitconfig

echo "==> Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "==> Adding Homebrew to PATH..."
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "==> Installing neovim and lazygit via Homebrew..."
brew install neovim lazygit

echo "==> Setting zsh as default shell..."
sudo chsh -s "$(which zsh)" $(whoami)

echo "==> Bootstrap complete! Please log out and back in for zsh to take effect."
