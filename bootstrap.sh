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

# Update .zshrc to source the plugins  
echo "Updating .zshrc..."  
{  
    echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"  
    echo "source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"  
} >> ${ZDOTDIR:-$HOME}/.zshrc  

# Install lazygit  
echo "Installing lazygit..."  
sudo add-apt-repository ppa:lazygit-team/release -y
sudo apt update -y
sudo apt install lazygit


echo "Setup complete!"
