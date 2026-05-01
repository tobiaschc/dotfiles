# Dotfiles

Personal dotfiles for shell, editor, terminal, and CLI tools.

Most of this repo is cross-platform and should work on Arch Linux, Ubuntu, and macOS.

## Supported Platforms

- Arch Linux
- Ubuntu
- macOS

## Required Packages

Install the basics first:

- `git`
- `stow`
- `zsh`

### Arch Linux

```sh
sudo pacman -S --needed git stow zsh
```

### Ubuntu

```sh
sudo apt update
sudo apt install -y git stow zsh
```

### macOS

```sh
brew install git stow zsh
```

## Optional Dependencies

Some parts of the shell and terminal setup become more useful if these are installed:

- `fzf`
- `ripgrep`
- `bat`
- `starship`
- `zoxide`
- `pyenv`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `zsh-history-substring-search`

The shell config checks for most of these and will skip them when they are missing.

On Ubuntu, `starship` and `zsh-history-substring-search` may need to be installed manually. Ubuntu also ships `bat` as `batcat`, and `install.sh` handles that by creating a local `bat` symlink.

## Zsh Setup

This repo keeps zsh config in `~/.config/zsh`, so zsh needs `ZDOTDIR` set before it starts.

You can set this either per-user or system-wide.

### Per-user

Add this to `~/.zshenv`:

```sh
export ZDOTDIR="$HOME/.config/zsh"
```

If `~/.zshenv` does not exist yet, create it with:

```sh
printf 'export ZDOTDIR="$HOME/.config/zsh"\n' > ~/.zshenv
```

### System-wide

If you want this applied system-wide instead:

On Arch Linux or Ubuntu, add it to `/etc/zsh/zshenv`:

```sh
echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zsh/zshenv
```

On macOS, add it to `/etc/zshenv`:

```sh
echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zshenv
```

## Installation

Clone the repository:

```sh
git clone git@github.com:tobias-chc/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

The simplest setup is the install script:

```sh
./install.sh
```

It can install packages, add `ZDOTDIR` to `~/.zshenv`, and run `stow .`.

Useful flags:

```sh
./install.sh --help
./install.sh --yes
./install.sh --devpod
./install.sh --skip-packages
```

### DevPod

For DevPod or similar remote workspace containers, use:

```sh
./install.sh --devpod
```

In DevPod mode, the script prioritizes user-level setup and will continue even when it cannot install system packages. That is usually what you want in a prebuilt workspace image.

## Manual Stow

This repo is meant to be stowed all at once into `~/.config`. The included `.stowrc` already sets that target, so you can run:

```sh
stow .
```

That will create symlinks such as:

- `~/.config/nvim -> ~/dotfiles/nvim`
- `~/.config/zsh -> ~/dotfiles/zsh`
- `~/.config/wezterm -> ~/dotfiles/wezterm`

and so on for the rest of the directories in the repo, including `aerospace/`.

## Platform Notes

`aerospace/` is macOS-specific, but it can still be stowed on Linux without causing problems. You can simply ignore it on Arch Linux and Ubuntu.

`vim/` is also stowed into `~/.config/vim` by this setup. If you want classic Vim config in `~/.vim` or `~/.vimrc`, that would require a different repo layout.

## Unstow

To remove the symlinks later:

```sh
stow -D .
```
