sudo apt update && sudo apt upgrade -y
# change to zsh
sudo apt install zsh git curl wget htop -y
chsh -s /bin/zsh
# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
