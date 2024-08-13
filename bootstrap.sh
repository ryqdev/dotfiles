#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

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




## This is a master script for all Linux & Windows Operating System which will install Docker and Docker Compose on various distros like Ubuntu, Debian,
## Scientific Linux, FreeBSD, Asianux, Alpine and many more

prepare_ubuntu() {
  sudo apt-get update
  sudo apt-get dist-upgrade -y
  sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    curl \
    gnupg-curl \
    htop \
    lsof \
    tree \
    tzdata \
    lsb-release \
    bzip2 \
    unzip \
    xz-utils
}

install_docker() {
  # Docker
  export CHANNEL=stable
  curl -fsSL https://get.docker.com/ | sh
  ## Add Docker daemon configuration
  cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "icc": false,
  "disable-legacy-registry": true,
  "userland-proxy": false,
  "live-restore": true
}
EOF
  ## Start docker service
  sudo systemctl enable docker
  sudo systemctl start docker
  ## Add current user to docker group
  sudo usermod -aG docker $USER

  ## show information
  docker version
  docker info
  
  }
  
  prepare_compose(){

  # Docker Compose
  sudo curl -L https://github.com/docker/compose/releases/download/1.21.0-rc1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  ## show docker-compose version
  docker-compose version
}

provision_docker() {
  echo "Provisioning ..."
  prepare_ubuntu
  install_docker
  # Downlaod the Dockerfile and docker-compose.yml

}

provision_compose(){
   echo "Provisioning Docker Compose  .."
   prepare_compose
 
}

command=$1
shift
case "$command" in
  provision_docker)      provision_docker $@ ;;
   *)        echo "Usage: <logs|provision_docker|provision_compose>" ;;
esac



echo "Setup complete!"
