# Homebrew
BREW_PATH=""
if [[ "$(uname)" == "Darwin" && -x "/opt/homebrew/bin/brew" ]]; then
  BREW_PATH="/opt/homebrew/bin/brew"
elif [[ "$(uname)" == "Linux" && -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
fi

if [[ -n "$BREW_PATH" ]]; then
  export HOMEBREW_NO_AUTO_UPDATE=1
  eval "$($BREW_PATH shellenv)"
  export ZSH_PLUGINS_DIR="$(brew --prefix)/share"
else
  export ZSH_PLUGINS_DIR="/usr/share/zsh/plugins"
fi

# Pipenv
export PIPENV_VENV_IN_PROJECT=1

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - --no-rehash)" # Initialize pyenv when a new shell spawns
fi

# Poetry
path=("$HOME/.local/bin" $path)
# alias poetry_shell='. "$(dirname $(poetry run which python))/activate"'

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# zoxide - a better cd command
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files

# Activate syntax highlighting
if [[ -f "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Change colors
# export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue

# Activate autosuggestions
if [[ -f "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]]; then
  source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
fi

# Activate history substring search
if [[ -f "${ZSH_PLUGINS_DIR}/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  source "${ZSH_PLUGINS_DIR}/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi
