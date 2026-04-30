# System
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'
if [[ "$(uname)" == "Darwin" ]]; then
  alias sleep='pmset sleepnow'
elif [[ "$(uname)" == "Linux" ]]; then
  alias suspend='sudo pm-suspend'
fi
alias c='clear'
alias e='exit'

# Safer file operations (prompt before overwrite/delete).
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# zhs config
alias reload-zsh='source ${ZDOTDIR:-$HOME}/.zshrc'
alias edit-zsh='nvim ${ZDOTDIR:-$HOME}/.zshrc'

# Stow
# alias stow='stow --target=$HOME/.config'
alias chkstow='chkstow --target=$HOME/.config'

# Git
alias g='git'
alias ga='git add'
alias gd='git diff'
alias gf='git fetch'
alias gs='git status'
alias gss='git status -s'
# pull commands
alias gpl='git pull'
alias gplo='git pull origin'
alias gpr='git pull --rebase'
# branch commands
alias gb='git branch '
alias gbr='git branch -r'
alias gres='git remote show'
# log commands
alias glgg='git log --graph --max-count=5 --decorate --pretty="oneline"'
# push commands
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias ggpush='git push origin $(current_branch)'
# commmit commands
alias gc='git commit -v'
alias gcm='git commit -m'
alias gcma='git commit --amend'
alias gcan='git commit --amend --no-edit'

# Folders
alias doc='cd $HOME/Documents'
alias dow='cd $HOME/Downloads'

# Eza, better ls
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'

# Detailed tree view
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ltree="eza --tree --level=2 --long --icons --git"

# Fzf with bat preview
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Better cat
alias cat="bat"
