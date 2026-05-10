# Secrets
[ -f "$HOME/.config/.env" ] && source "$HOME/.config/.env"

# Deduplicate PATH entries while preserving order.
typeset -U path PATH

# XDG Base directory specification
export XDG_CONFIG_HOME="$HOME/.config"         # Config files
export XDG_CACHE_HOME="$HOME/.cache"           # Cache files
export XDG_DATA_HOME="$HOME/.local/share"      # Application data
export XDG_STATE_HOME="$HOME/.local/state"     # Logs and state files

# Themes (onedark or nord)
export TMUX_THEME="nord"
export NVIM_THEME="nord"
export STARSHIP_THEME="nord"
export WEZTERM_THEME="nord"
#export BAT_THEME=tokyonight_night

# Update python files colors
export LS_COLORS="${LS_COLORS}:*.py=38;5;159"

# Locale settings
export LANG="en_US.UTF-8" # Sets default locale for all categories

# Use Neovim as default editor
export EDITOR="nvim"
export VISUAL="nvim"

# Add /usr/local/bin to the beginning of the PATH environment variable.
# This ensures that executables in /usr/local/bin are found before other directories in the PATH.
path=(/usr/local/bin $path)
