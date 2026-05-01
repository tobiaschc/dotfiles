#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHENV_FILE="${HOME}/.zshenv"
ZDOTDIR_LINE='export ZDOTDIR="$HOME/.config/zsh"'

AUTO_YES=0
SKIP_PACKAGES=0
SKIP_ZDOTDIR=0
SKIP_STOW=0
DEVPOD_MODE=0

log() {
  printf '[dotfiles] %s\n' "$1"
}

warn() {
  printf '[dotfiles] warning: %s\n' "$1" >&2
}

die() {
  printf '[dotfiles] error: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -y, --yes            Run without confirmation prompts
      --devpod         Optimize for DevPod or other remote workspace containers
      --skip-packages  Skip package installation
      --skip-zdotdir   Skip ~/.zshenv setup
      --skip-stow      Skip stow
  -h, --help           Show this help message
EOF
}

confirm() {
  local prompt="$1"

  if [[ "$AUTO_YES" -eq 1 ]]; then
    return 0
  fi

  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

sudo_cmd() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
  else
    return 1
  fi
}

can_install_packages() {
  if command -v sudo >/dev/null 2>&1; then
    return 0
  fi

  [[ "${EUID:-$(id -u)}" -eq 0 ]]
}

detect_platform() {
  local uname_s
  uname_s="$(uname -s)"

  if [[ "$uname_s" == "Darwin" ]]; then
    PLATFORM="macos"
    return
  fi

  if [[ "$uname_s" == "Linux" ]]; then
    if [[ -r /etc/os-release ]]; then
      . /etc/os-release
      case "${ID:-}" in
        arch)
          PLATFORM="arch"
          return
          ;;
        ubuntu)
          PLATFORM="ubuntu"
          return
          ;;
      esac
    fi
    die "unsupported Linux distribution; supported: Arch Linux, Ubuntu"
  fi

  die "unsupported operating system: $uname_s"
}

install_arch_packages() {
  can_install_packages || return 1
  sudo_cmd pacman -S --needed \
    git stow zsh \
    fzf ripgrep bat starship zoxide pyenv \
    zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
    tree-sitter-cli
}

install_ubuntu_packages() {
  can_install_packages || return 1
  sudo_cmd apt update
  sudo_cmd apt install -y \
    git stow zsh \
    fzf ripgrep bat zoxide pyenv \
    zsh-autosuggestions zsh-syntax-highlighting

  warn "Ubuntu packages for starship and zsh-history-substring-search are not installed by this script."
  warn "Install starship manually from its upstream release or install script if you want it."

  if command -v npm >/dev/null 2>&1; then
    npm install -g tree-sitter-cli
  else
    warn "npm not found; skipping tree-sitter-cli install (required by nvim-treesitter)."
    warn "Install it manually: npm install -g tree-sitter-cli"
  fi
}

install_macos_packages() {
  need_cmd brew
  brew install \
    git stow zsh \
    fzf ripgrep bat starship zoxide pyenv \
    zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
  npm install -g tree-sitter-cli
}

install_packages() {
  case "$PLATFORM" in
    arch)
      install_arch_packages
      ;;
    ubuntu)
      install_ubuntu_packages
      ;;
    macos)
      install_macos_packages
      ;;
  esac
}

detect_devpod() {
  [[ "${DEVPOD:-}" == "true" ]] \
    || [[ -n "${DEVPOD_WORKSPACE_ID:-}" ]] \
    || [[ -n "${REMOTE_CONTAINERS:-}" ]]
}

setup_bat_alias() {
  if [[ "$PLATFORM" != "ubuntu" ]]; then
    return
  fi

  if command -v bat >/dev/null 2>&1; then
    return
  fi

  if command -v batcat >/dev/null 2>&1; then
    mkdir -p "${HOME}/.local/bin"
    ln -sfn /usr/bin/batcat "${HOME}/.local/bin/bat"
    log "linked ~/.local/bin/bat to /usr/bin/batcat"
  fi
}

setup_zdotdir() {
  mkdir -p "${HOME}/.config"

  if [[ -f "$ZSHENV_FILE" ]] && grep -Fqx "$ZDOTDIR_LINE" "$ZSHENV_FILE"; then
    log "~/.zshenv already configures ZDOTDIR"
    return
  fi

  {
    printf '\n'
    printf '%s\n' "$ZDOTDIR_LINE"
  } >> "$ZSHENV_FILE"

  log "updated $ZSHENV_FILE"
}

run_stow() {
  cd "$REPO_DIR"
  mkdir -p "${HOME}/.config"
  stow .
  log "stowed dotfiles into ~/.config"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y|--yes)
        AUTO_YES=1
        ;;
      --devpod)
        DEVPOD_MODE=1
        ;;
      --skip-packages)
        SKIP_PACKAGES=1
        ;;
      --skip-zdotdir)
        SKIP_ZDOTDIR=1
        ;;
      --skip-stow)
        SKIP_STOW=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage
        die "unknown option: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  detect_platform

  if detect_devpod; then
    DEVPOD_MODE=1
  fi

  log "platform: $PLATFORM"
  log "repo: $REPO_DIR"
  if [[ "$DEVPOD_MODE" -eq 1 ]]; then
    log "workspace mode: devpod"
  fi

  if [[ "$DEVPOD_MODE" -eq 1 && "$SKIP_PACKAGES" -eq 0 && ! -t 0 ]]; then
    SKIP_PACKAGES=1
    log "skipping package installation in devpod mode without a tty"
  fi

  if [[ "$SKIP_PACKAGES" -eq 0 ]] && confirm "Install required and optional packages?"; then
    if install_packages; then
      setup_bat_alias
    elif [[ "$DEVPOD_MODE" -eq 1 ]]; then
      warn "package installation skipped; continuing with user-level setup"
      warn "install system packages in the DevPod image or workspace if you need them"
    else
      die "package installation failed"
    fi
  fi

  if [[ "$SKIP_ZDOTDIR" -eq 0 ]] && confirm "Configure ZDOTDIR in ~/.zshenv?"; then
    setup_zdotdir
  fi

  if [[ "$SKIP_STOW" -eq 0 ]] && confirm "Stow this repo into ~/.config now?"; then
    need_cmd stow
    run_stow
  fi

  log "done"
}

main "$@"
