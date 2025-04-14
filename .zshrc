#!/bin/zsh

# Setup command's history 
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000


# Env
export XDG_CONFIG_HOME=/home/neo/.config/nvim
export PNPM_HOME=/home/neo/.local/share/pnpm
# export NVM_DIR="$HOME/.config/nvim/nvm"
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_AUTO_USE=true


# Sources 
source ~/Repos/znap/znap.zsh # Znap
source $HOME/.config/nvim/zshrc.d/dots-hyprland.zsh # Source color generated from end4 dotfile
source /home/neo/.zsh/pd-complete.zsh
source /home/neo/.zsh/ps-complete.zsh
source /home/neo/.zsh/pnpm-complete.zsh

# source ./.zsh/nvm_lazy_load.sh # Lazy load nvm
# [[ -r $NVM_DIR/bash_completion ]] && source $NVM_DIR/bash_completion
# source ./.zsh/autoload_nvm.sh #  Auto switch nvm version.

# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Starts plugins.
# znap source nvm
znap source zsh-users/zsh-syntax-highlighting
znap source marlonrichert/zsh-autocomplete
znap source marlonrichert/zsh-edit
znap source lukechilds/zsh-nvm

# znap source jeffreytse/zsh-vi-mode


# Workaround for the zsh-autocomplete's realtime complete to work
# Github issue : https://github.com/marlonrichert/zsh-autocomplete/issues/761
setopt interactivecomments


# `znap eval` makes evaluating generated command output up to 10 times faster.
# znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# `znap function` lets you lazy-load features you don't always need.
# znap function _pyenv pyenv "znap eval pyenv 'pyenv init - --no-rehash'"
# compctl -K    _pyenv pyenv

# `znap install` adds new commands and completions.
# znap install aureliojargas/clitest zsh-users/zsh-completions

# Add this to your .zshrc file if it's not already there
autoload -Uz compinit
compinit


# Initialize 
eval "$(starship init zsh)" # Starship
eval "$(zoxide init zsh)"


eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/clt > /dev/null 2>&1

zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([1-9]#) ([0-9a-z-]#)*=01;34=0=01'


# bindkey -v


bindkey -r '^j'
bindkey -M menuselect '\r' .accept-line

# [ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Alisases
# General
alias cls='clear'

# Better ls
alias l="eza --icons=always"
alias ls="eza --icons=always -a"
alias ll="eza -lg --icons=always"
alias la="eza -lag --icons=always"
alias lt="eza -lTg --icons=always"

# Better cd
alias cd='z' # Show hidden files

# Openvpn
alias vpnon='openvpn3 session-start --config /etc/openvpn/Profile3.ovpn'
alias vpnoff='openvpn3 session-manage --config /etc/openvpn/Profile3.ovpn --disconnect'

# Docker compose
alias dockerup="sudo docker compose -f /home/neo/Neo/Work/ceh-do/docker-compose.dev.yml up -d"
alias dockerdown="sudo docker compose -f /home/neo/Neo/Work/ceh-do/docker-compose.dev.yml down"


# Warp
alias warpcheck="curl https://www.cloudflare.com/cdn-cgi/trace/"
alias warpon="warp-cli connect"
alias warpoff="warp-cli disconnect"
alias gg="setsid google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland > /dev/null 2>&1 &"
alias gge='setsid google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland > /dev/null 2>&1 & disown && exit'

# Pnpm
alias pdb='pnpm start:debug'

alias dbsg='cloudflared access tcp --hostname ceh-db.trisma.io.vn --url localhost:5433'





# Nvim
alias vim="nvim"
alias vi="nvim"
alias n="nvim"
alias nv="nvim"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# Run fetch
macchina

