# This .zshrc is in manjaro i3

# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi


######################
#      PATH and ENV  #
######################
export PATH="/home/ryqdev/.local/share/JetBrains/Toolbox/scripts":$PATH


export http_proxy="http://127.0.0.1:10809"
export https_proxy="http://127.0.0.1:10809"

######################
#      ALIAS         #
######################
alias lc="leetcode"
alias o="xdg-open"
alias copy="xclip -sel clip"
alias v="nvim"

alias reignore='git rm -r --cached . && git add .'
alias whyignore='git check-ignore -v'
alias gg='git lg'
alias gb='git branch'
alias gco='git checkout'
alias gac="git add . && git commit"
alias gs="git status"

# Tmux
alias tn="tmux new -s"
alias ta="tmux attach"
alias lg="lazygit"
alias i="idea"
alias lc="leetcode"

alias nchat="/opt/google/chrome/google-chrome --profile-directory=Default --app-id=mpcbpmlmfjaegepeeibkefjemdmadcme"



######################
#      Anaconda      #
######################
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/ryqdev/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ryqdev/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ryqdev/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ryqdev/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



######################
#       Tools        #
######################

# autojump
[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh

# opam configuration
[[ ! -r /home/ryqdev/.opam/opam-init/init.zsh ]] || source /home/ryqdev/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

setxkbmap -option caps:ctrl_modifier
xset r rate 200 25


# fzf in Arch Linux. From version 0.48 onwards, this can be accomplished with a single line:
source <(fzf --zsh)
