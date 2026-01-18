#!/bin/bash
set -e

echo "==> Updating apt..."
sudo apt update

echo "==> Installing build-essential..."
sudo apt install -y build-essential

echo "==> Installing zsh..."
sudo apt install -y zsh

echo "==> Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "==> Adding Homebrew to PATH..."
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "==> Installing neovim and lazygit via Homebrew..."
brew install neovim lazygit

echo "==> Cloning dotfiles..."
git clone https://github.com/ryqdev/dotfiles.git ~/dotfiles

echo "==> Creating ~/.config directory..."
mkdir -p ~/.config

echo "==> Copying nvim and tmux configs..."
cp -r ~/dotfiles/.config/nvim ~/.config/
cp -r ~/dotfiles/.config/tmux ~/.config/
cp -r ~/dotfiles/.config/lazygit ~/.config/

echo "==> Copying .zshrc and .gitconfig ..."
cp ~/dotfiles/.zshrc ~/.zshrc
cp ~/dotfiles/.gitconfig ~/.gitconfig

echo "==> Setting zsh as default shell..."
sudo chsh -s "$(which zsh)" $(whoami)

echo "==> Bootstrap complete! Please log out and back in for zsh to take effect."
