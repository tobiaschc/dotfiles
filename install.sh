#!/usr/bin/env bash
#
# install.sh — dotfiles installer (Linux only: Arch Linux, Ubuntu/Debian)
#
# Usage:
#   ./install.sh                    # interactive
#   ./install.sh --yes              # non-interactive, assume yes to prompts
#   ./install.sh --skip-packages    # only set ZDOTDIR + stow, skip installs
#   ./install.sh --devpod           # tolerate missing sudo (containers/devpods)
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=0
SKIP_PACKAGES=0
DEVPOD=0

for arg in "$@"; do
  case "$arg" in
    --yes) ASSUME_YES=1 ;;
    --skip-packages) SKIP_PACKAGES=1 ;;
    --devpod) DEVPOD=1 ;;
    -h|--help)
      grep '^#' "${BASH_SOURCE[0]}" | sed 's/^#//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log()  { printf '\033[1;34m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

confirm() {
  local prompt="$1"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi
  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# Guard: this repo targets Linux only, never run pyenv/etc. as root
# ---------------------------------------------------------------------------
if [[ "$(uname)" != "Linux" ]]; then
  err "This install.sh only supports Linux (Arch Linux, Ubuntu/Debian). Detected: $(uname)"
  exit 1
fi

if [[ "$EUID" -eq 0 && "$DEVPOD" -eq 0 ]]; then
  err "Do not run this script as root — it installs user dotfiles into \$HOME."
  err "Run it as your normal user; sudo will be invoked only for package installs."
  err "(If you are provisioning a container as root on purpose, pass --devpod.)"
  exit 1
fi

# ---------------------------------------------------------------------------
# Detect distro
# ---------------------------------------------------------------------------
DISTRO=""
if command -v pacman >/dev/null 2>&1; then
  DISTRO="arch"
elif command -v apt-get >/dev/null 2>&1; then
  DISTRO="debian"
else
  err "Unsupported distro — this script supports Arch Linux (pacman) and Debian/Ubuntu (apt) only."
  exit 1
fi
log "Detected distro family: $DISTRO"

# ---------------------------------------------------------------------------
# sudo detection
# ---------------------------------------------------------------------------
HAVE_SUDO=0
if [[ "$EUID" -eq 0 ]]; then
  HAVE_SUDO=1
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  HAVE_SUDO=1
elif command -v sudo >/dev/null 2>&1; then
  # sudo exists but needs an interactive password — that's fine outside --devpod
  if [[ "$DEVPOD" -eq 0 ]]; then
    HAVE_SUDO=1
  fi
fi

as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  elif [[ "$HAVE_SUDO" -eq 1 ]]; then
    sudo "$@"
  else
    warn "No sudo access — skipping: $*"
    return 1
  fi
}

if [[ "$HAVE_SUDO" -eq 0 && "$SKIP_PACKAGES" -eq 0 ]]; then
  warn "No sudo available. Package installation will be skipped."
  warn "Ask an administrator to run: usermod -aG sudo \$(whoami)  (Debian/Ubuntu)"
  warn "or add the user to the wheel group + /etc/sudoers (Arch)."
  SKIP_PACKAGES=1
fi

# ---------------------------------------------------------------------------
# Package installation
# ---------------------------------------------------------------------------
REQUIRED_PKGS_ARCH=(git stow zsh)
REQUIRED_PKGS_DEBIAN=(git stow zsh)

# Packages available directly from the distro's repos with matching names.
# Neovim is excluded from the Debian list: Debian/Ubuntu apt ships Neovim
# 0.10.x, which predates the vim.hl module (added in 0.11) that this config
# uses in lua/core/snippets.lua — install_neovim_debian() below pulls the
# current upstream release instead. Arch's pacman tracks upstream closely
# enough to use directly.
OPTIONAL_PKGS_ARCH=(fzf ripgrep bat eza zoxide neovim lazygit github-cli zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)
OPTIONAL_PKGS_DEBIAN=(fzf ripgrep bat eza zoxide lazygit gh zsh-autosuggestions zsh-syntax-highlighting)

install_packages() {
  if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
    log "Skipping package installation (--skip-packages or no sudo)."
    return
  fi

  case "$DISTRO" in
    arch)
      log "Installing required packages: ${REQUIRED_PKGS_ARCH[*]}"
      as_root pacman -Sy --needed --noconfirm "${REQUIRED_PKGS_ARCH[@]}" || true
      if confirm "Install optional packages too? (${OPTIONAL_PKGS_ARCH[*]})"; then
        as_root pacman -S --needed --noconfirm "${OPTIONAL_PKGS_ARCH[@]}" || true
      fi
      ;;
    debian)
      log "Installing required packages: ${REQUIRED_PKGS_DEBIAN[*]}"
      as_root apt-get update -y || true
      as_root apt-get install -y "${REQUIRED_PKGS_DEBIAN[@]}" || true
      if confirm "Install optional packages too? (${OPTIONAL_PKGS_DEBIAN[*]})"; then
        as_root apt-get install -y "${OPTIONAL_PKGS_DEBIAN[@]}" || true
      fi
      # zsh-history-substring-search has no Debian package — clone it directly
      # into the path custom.zsh expects.
      local plugin_dir="/usr/share/zsh/plugins/zsh-history-substring-search"
      if [[ ! -d "$plugin_dir" ]]; then
        log "zsh-history-substring-search has no Debian package — cloning from source."
        as_root mkdir -p /usr/share/zsh/plugins
        as_root git clone --depth 1 \
          https://github.com/zsh-users/zsh-history-substring-search \
          "$plugin_dir" || warn "Could not clone zsh-history-substring-search"
      fi
      ;;
  esac
}

# Debian installs zsh-autosuggestions / zsh-syntax-highlighting under
# /usr/share/<name>/ instead of the /usr/share/zsh/plugins/<name>/ path that
# custom.zsh looks for — symlink them into place.
fix_debian_zsh_plugin_paths() {
  [[ "$DISTRO" == "debian" ]] || return 0
  [[ "$SKIP_PACKAGES" -eq 1 ]] && return 0

  as_root mkdir -p /usr/share/zsh/plugins
  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    local src="/usr/share/$plugin"
    local dest="/usr/share/zsh/plugins/$plugin"
    if [[ -d "$src" && ! -e "$dest" ]]; then
      log "Linking $dest -> $src"
      as_root ln -sf "$src" "$dest"
    fi
  done
}

# bat ships as `batcat` on Debian/Ubuntu to avoid a name clash; symlink `bat`
# into ~/.local/bin so aliases and fzf previews that call `bat` work.
fix_debian_bat_symlink() {
  [[ "$DISTRO" == "debian" ]] || return 0
  command -v batcat >/dev/null 2>&1 || return 0
  command -v bat >/dev/null 2>&1 && return 0

  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  log "Linked ~/.local/bin/bat -> $(command -v batcat)"
}

# starship and pyenv are not packaged (or not current enough) on either
# distro's default repos — always install via their official scripts.
install_starship() {
  command -v starship >/dev/null 2>&1 && { log "starship already installed."; return; }
  confirm "Install starship prompt (official install script)?" || return 0
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

install_pyenv() {
  [[ -d "$HOME/.pyenv" ]] && { log "pyenv already installed at ~/.pyenv."; return; }
  confirm "Install pyenv (official install script)?" || return 0
  # Never run this as root — it must land in the real user's $HOME.
  if [[ "$EUID" -eq 0 ]]; then
    warn "Refusing to install pyenv as root (would land in /root/.pyenv, not the user's home)."
    warn "Re-run this script as the target user instead."
    return
  fi
  curl https://pyenv.run | bash
}

# Debian/Ubuntu apt ships Neovim 0.10.x. This config uses vim.hl (added in
# 0.11), so on Debian we install the current upstream release binary instead
# of relying on apt. Arch's pacman is close enough to upstream and is handled
# via the normal package list above.
NEOVIM_MIN_MAJOR=0
NEOVIM_MIN_MINOR=11

install_neovim_debian() {
  [[ "$DISTRO" == "debian" ]] || return 0

  if command -v nvim >/dev/null 2>&1; then
    local ver major minor
    ver="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    major="${ver%%.*}"
    minor="$(echo "$ver" | cut -d. -f2)"
    if [[ "$major" -gt "$NEOVIM_MIN_MAJOR" || ("$major" -eq "$NEOVIM_MIN_MAJOR" && "$minor" -ge "$NEOVIM_MIN_MINOR") ]]; then
      log "Neovim $ver already installed and >= 0.11 — skipping."
      return
    fi
    warn "Neovim $ver is older than 0.11 (needed for vim.hl) — installing current release."
  fi

  confirm "Install current Neovim from upstream GitHub release (apt's is too old)?" || return 0

  local arch tarball tmp
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Unsupported architecture for upstream Neovim release: $(uname -m). Skipping."; return ;;
  esac

  tmp="$(mktemp -d)"
  tarball="nvim-linux-${arch}.tar.gz"
  log "Downloading Neovim release for linux-${arch}..."
  curl -fLo "$tmp/$tarball" "https://github.com/neovim/neovim/releases/latest/download/$tarball"

  as_root rm -rf "/opt/nvim-linux-${arch}"
  as_root tar -C /opt -xzf "$tmp/$tarball"
  as_root ln -sf "/opt/nvim-linux-${arch}/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"

  log "Installed: $(nvim --version | head -1)"
}

# ---------------------------------------------------------------------------
# ZDOTDIR
# ---------------------------------------------------------------------------
setup_zdotdir() {
  local zshenv="$HOME/.zshenv"
  local line='export ZDOTDIR="$HOME/.config/zsh"'

  if [[ -f "$zshenv" ]] && grep -qF 'ZDOTDIR' "$zshenv"; then
    log "ZDOTDIR already configured in $zshenv"
    return
  fi

  log "Setting ZDOTDIR in $zshenv"
  printf '%s\n' "$line" >> "$zshenv"
}

# ---------------------------------------------------------------------------
# Stow
# ---------------------------------------------------------------------------
stow_dotfiles() {
  # aerospace/ is macOS-only tiling WM config; this installer is Linux-only,
  # so it is excluded from the stow set entirely.
  local packages=()
  for dir in "$DOTFILES_DIR"/*/; do
    local name
    name="$(basename "$dir")"
    [[ "$name" == "aerospace" ]] && continue
    packages+=("$name")
  done

  log "Stowing packages: ${packages[*]}"
  cd "$DOTFILES_DIR"
  stow "${packages[@]}"
}

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  [[ -z "$zsh_path" ]] && return

  if [[ "$SHELL" == "$zsh_path" ]]; then
    log "zsh is already the default shell."
    return
  fi

  if [[ "$HAVE_SUDO" -eq 0 ]]; then
    warn "No sudo access — cannot run chsh. Ask an administrator to run:"
    warn "  chsh -s $zsh_path $(whoami)"
    return
  fi

  confirm "Set zsh ($zsh_path) as your default login shell?" || return 0
  chsh -s "$zsh_path" "$(whoami)" || warn "chsh failed — set the default shell manually."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  install_packages
  fix_debian_zsh_plugin_paths
  fix_debian_bat_symlink
  install_neovim_debian
  install_starship
  install_pyenv
  setup_zdotdir
  stow_dotfiles
  set_default_shell

  log "Done. Open a new shell (or log out/in) to pick up the zsh config."
  log "Note: aerospace/, hypr/, waybar/ are skipped/inert as appropriate outside their target platform."
}

main
