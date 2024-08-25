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
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Setting up dotfiles
rm ~/.zshrc

# for github codespace
# ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.zshrc ~/.zshrc 
# ln -s /workspaces/.codespaces/.persistedshare/dotfiles/.gitconfig ~/.gitconfig

# for gitpod
ln -s /home/gitpod/.dotfiles/.zshrc ~/.zshrc 
ln -s /home/gitpod/.dotfiles/.gitconfig ~/.gitconfig


echo "Setup complete!"
