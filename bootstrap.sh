#!/bin/bash  

# Exit immediately if a command exits with a non-zero status.  
set -e  
set -x  # Enable debugging  

# Install Rust  
echo "Installing Rust..."  
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y  
source $HOME/.cargo/env  

# Install required packages and change shell to zsh  
echo "Changing shell to zsh and installing required packages..."  
sudo apt-get install -y zsh git curl wget htop  

# Install zsh-autosuggestions  
echo "Installing zsh-autosuggestions..."  
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions  

# Install zsh-syntax-highlighting  
echo "Installing zsh-syntax-highlighting..."  
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting  

# Install lazygit  
echo "Installing lazygit..."  
sudo add-apt-repository ppa:lazygit-team/release -y
sudo apt update -y
sudo apt install lazygit


# Setting up dotfiles
rm ~/.zshrc
ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.zshrc ~/.zshrc 
ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.gitconfig ~/.gitconfig

# neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update -y
sudo apt-get install neovim -y

# Installing lazyvim
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "Setup complete!"
