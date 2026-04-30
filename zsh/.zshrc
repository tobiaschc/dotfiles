# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
HISTORY_SUBSTRING_SEARCH_PREFIXED=true
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down

# Command line navigation (reliable across terminals)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
[[ -n "${terminfo[khome]}" ]] && bindkey "${terminfo[khome]}" beginning-of-line
[[ -n "${terminfo[kend]}" ]] && bindkey "${terminfo[kend]}" end-of-line

# Word-wise navigation
bindkey '^[b' backward-word   # Alt-b
bindkey '^[f' forward-word    # Alt-f
[[ -n "${terminfo[kLFT5]}" ]] && bindkey "${terminfo[kLFT5]}" backward-word
[[ -n "${terminfo[kRIT5]}" ]] && bindkey "${terminfo[kRIT5]}" forward-word

# Common fallback escape sequences for Ctrl+Left / Ctrl+Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Functions
[ -f "$HOME/.config/zsh/functions.zsh" ] && source "$HOME/.config/zsh/functions.zsh"
