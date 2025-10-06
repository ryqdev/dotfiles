#!/usr/bin/env bash
set -euo pipefail

# Minimal, portable bootstrap for ryqdev/dotfiles
# - Installs zsh configs: ~/.zshrc, ~/.zimrc
# - Installs fzf config:  ~/.config/fzf/fzf.zsh
# - Syncs Neovim config:  ~/.config/nvim (replaces existing)
# - Installs lazygit if missing (brew/apt/pacman, or GitHub release fallback)

REPO_OWNER="ryqdev"
REPO_NAME="dotfiles"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/main"

OS="$(uname -s)"
ARCH="$(uname -m)"
XDG_CONFIG_HOME_DEFAULT="$HOME/.config"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$XDG_CONFIG_HOME_DEFAULT}"

have() { command -v "$1" >/dev/null 2>&1; }

msg() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[err]\033[0m %s\n" "$*"; }

BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
backup_path() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
    msg "Backed up ${target} -> ${BACKUP_DIR}/"
  fi
}

obtain_repo_dir() {
  # Sets global SRC_DIR to a path with repo contents
  local tmp
  tmp="$(mktemp -d)"
  if have git; then
    msg "Cloning ${REPO_URL} (shallow)…"
    git clone --depth=1 "${REPO_URL}.git" "$tmp" >/dev/null 2>&1 || {
      err "git clone failed"; rm -rf "$tmp"; return 1; }
    SRC_DIR="$tmp"
  else
    msg "Fetching tarball (no git detected)…"
    # codeload provides a tar.gz; extract first directory
    curl -fsSL "https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/refs/heads/main" |
      tar -xz -C "$tmp" || { err "tarball download/extract failed"; rm -rf "$tmp"; return 1; }
    local inner
    inner="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)"
    if [ -z "$inner" ] || [ ! -d "$inner" ]; then
      err "could not locate extracted repository directory"
      rm -rf "$tmp"
      return 1
    fi
    SRC_DIR="$inner"
  fi
}

install_file() {
  # install_file <src> <dest>
  local src="$1" dest="$2"
  if [ ! -f "$src" ]; then err "Missing source file: $src"; return 1; fi
  mkdir -p "$(dirname "$dest")"
  backup_path "$dest"
  cp -f "$src" "$dest"
  msg "Installed $(basename "$dest") -> $dest"
}

install_dir_replace() {
  # install_dir_replace <src_dir> <dest_dir>
  local src="$1" dest="$2"
  if [ ! -d "$src" ]; then err "Missing source dir: $src"; return 1; fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_path "$dest"
  fi
  # Ensure destination does not exist so cp copies the directory as <dest>
  rm -rf "$dest"
  cp -R "$src" "$dest"
  msg "Synced directory $(basename "$dest") -> $dest"
}

install_lazygit() {
  if have lazygit; then
    msg "lazygit already installed"
    return 0
  fi

  msg "Installing lazygit…"

  # Prefer native package managers
  if [ "$OS" = "Darwin" ]; then
    if have brew; then
      brew install lazygit && return 0 || warn "brew install lazygit failed"
    fi
  elif [ -f /etc/debian_version ] && have apt-get; then
    sudo apt-get update && sudo apt-get install -y lazygit && return 0 || warn "apt install lazygit failed"
  elif [ -f /etc/arch-release ] && have pacman; then
    sudo pacman -Sy --noconfirm lazygit && return 0 || warn "pacman install lazygit failed"
  fi

  # Fallback to GitHub releases
  local version asset tmp install_to
  version="$(
    curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
      sed -n 's/.*"tag_name": "v\([^"]*\)".*/\1/p' | head -n1
  )"
  if [ -z "$version" ]; then
    err "Unable to determine latest lazygit version"
    return 1
  fi

  case "$OS" in
    Darwin)
      case "$ARCH" in
        arm64|aarch64) asset="lazygit_${version}_Darwin_arm64.tar.gz" ;;
        x86_64|amd64)  asset="lazygit_${version}_Darwin_x86_64.tar.gz" ;;
        *) err "Unsupported macOS arch: $ARCH"; return 1 ;;
      esac
      ;;
    Linux)
      case "$ARCH" in
        x86_64|amd64) asset="lazygit_${version}_Linux_x86_64.tar.gz" ;;
        arm64|aarch64) asset="lazygit_${version}_Linux_arm64.tar.gz" ;;
        armv7l|armv7) asset="lazygit_${version}_Linux_armv7.tar.gz" ;;
        *) err "Unsupported Linux arch: $ARCH"; return 1 ;;
      esac
      ;;
    *)
      err "Unsupported OS for lazygit fallback: $OS"
      return 1
      ;;
  esac

  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/lazygit.tgz" "https://github.com/jesseduffield/lazygit/releases/latest/download/${asset}"
  tar -xzf "$tmp/lazygit.tgz" -C "$tmp" lazygit

  if have sudo; then
    sudo install "$tmp/lazygit" /usr/local/bin/lazygit || warn "sudo install failed; falling back to ~/.local/bin"
  fi
  if ! have lazygit; then
    install_to="$HOME/.local/bin"
    mkdir -p "$install_to"
    install "$tmp/lazygit" "$install_to/lazygit"
    msg "Installed lazygit to $install_to; ensure it is in PATH"
  fi
  rm -rf "$tmp"
}

main() {
  msg "Starting bootstrap for ${REPO_OWNER}/${REPO_NAME}"

  # Prepare repo contents
  local SRC_DIR
  obtain_repo_dir

  # Install Zsh config files
  install_file "$SRC_DIR/.zshrc" "$HOME/.zshrc"
  install_file "$SRC_DIR/.zimrc" "$HOME/.zimrc"

  # Install fzf config
  install_file "$SRC_DIR/fzf.zsh" "$XDG_CONFIG_HOME/fzf/fzf.zsh"

  # Sync Neovim config directory
  install_dir_replace "$SRC_DIR/.config/nvim" "$XDG_CONFIG_HOME/nvim"

  # Ensure lazygit present
  install_lazygit || warn "lazygit installation skipped or failed"

  # Optionally source fzf.zsh if user's .zshrc doesn't already load fzf config
  if ! grep -q "fzf --zsh" "$HOME/.zshrc" 2>/dev/null && ! grep -q "fzf\.zsh" "$HOME/.zshrc" 2>/dev/null; then
    printf '\n# Load fzf key-bindings and completion\nsource "%s/fzf/fzf.zsh"\n' "$XDG_CONFIG_HOME" >> "$HOME/.zshrc"
    msg "Appended fzf sourcing line to ~/.zshrc"
  fi

  msg "Bootstrap complete. Open a new shell to apply Zsh config."
}

main "$@"

