# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed with GNU Stow. All top-level directories are stowed as-is into `~/.config`, so `nvim/` becomes `~/.config/nvim`, `zsh/` becomes `~/.config/zsh`, etc. The `.stowrc` already sets `--target=$HOME/.config`.

## Installation

```sh
# Full interactive setup (packages + ZDOTDIR + stow)
./install.sh

# Non-interactive
./install.sh --yes

# DevPod / remote containers (tolerates missing sudo)
./install.sh --devpod

# Just re-link dotfiles (assumes packages already installed)
./install.sh --skip-packages --yes
```

After editing files in this repo, re-stow to propagate symlinks:

```sh
stow .       # apply / update symlinks
stow -D .    # remove all symlinks
```

Zsh requires `ZDOTDIR="$HOME/.config/zsh"` in `~/.zshenv` before it will pick up the config here.

## Neovim config structure (`nvim/`)

Entry point: `nvim/init.lua` — loads core modules then sets up Lazy.nvim.

- `lua/core/` — options, keymaps, snippets, and the theme switcher
- `lua/plugins/` — one file per plugin spec (Lazy.nvim format)
- `lua/themes/` — nord, ethereal, matteblack (all loaded; active one set at startup)
- `lua/functions/` — small utility modules (git fugitive float, style helpers)

**Theme system:** Active theme is controlled by the `NVIM_THEME` env var (default: `nord`). At runtime use `:SwitchTheme [name]` or `<leader>sc` to pick interactively. Available themes: `nord`, `ethereal`, `matteblack`.

**Lua formatting:** StyLua is the formatter. Config is at `nvim/.stylua.toml` — 2-space indent, 160 column width, single quotes preferred.

## Hyprland config (`hypr/`)

Hyprland config sources Omarchy defaults first (`~/.local/share/omarchy/default/hypr/`), then the personal overrides in `hypr/`. **Do not edit the Omarchy defaults directly.** Personal overrides win because they are sourced last.

Override files:

- `monitors.conf` — display layout
- `input.conf` — keyboard/mouse settings
- `bindings.conf` — custom keybindings
- `looknfeel.conf` — gaps, borders, animations
- `autostart.conf` — startup apps

## Zsh config (`zsh/`)

- `.zshenv` — sets `ZDOTDIR` so zsh finds the rest
- `.zshrc` — history, keybindings, sources the three files below
- `custom.zsh` — env vars, plugin activation (starship, zoxide, fzf, pyenv, Homebrew)
- `aliases.zsh` — shell aliases
- `functions.zsh` — shell functions

`custom.zsh` detects platform (macOS vs Linux) and Homebrew presence to set `ZSH_PLUGINS_DIR` and load plugins from the right path.

## Platform notes

- `aerospace/` is macOS-only (tiling WM). Harmless to stow on Linux.
- `hypr/` and `waybar/` are Linux/Wayland-only.
- `vim/` is stowed into `~/.config/vim`, not `~/.vim`.
- On Ubuntu, `bat` is installed as `batcat`; `install.sh` creates a `~/.local/bin/bat` symlink automatically.
