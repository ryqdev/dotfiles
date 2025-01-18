# homebrew
xcode-select —-install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install softwares
brew install --cask iterm2
brew install --cask google-chrome
brew install --cask wechat
brew install --cask telegram
brew install --cask whatsapp
brew install --cask typora
brew install --cask remember-the-milk
brew install --cask dropbox
brew install visual-studio-code
brew install hyperswitch
brew install bob
brew install keepassxc
brew install iina
brew install spotify
brew install docker

# zsh
brew install zsh

# change shell to zsh
chsh -s /bin/zsh

# oh my zsh
brew install wget curl git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# install useful CLI softwares
brew install autojump
brew install ranger

brew install zsh-syntax-highlighting
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

brew install zsh-autosuggestions
#git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

brew install tmux
brew install gcc
brew insatll tree

# install neovim
brew install neovim
