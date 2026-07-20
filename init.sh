#!/usr/bin/env bash
# Bootstrap a new machine: install packages, stow the dotfiles,
# generate an SSH key and register it with GitHub.
# Idempotent — safe to re-run.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(zsh tmux nvim pi)
SSH_KEY="$HOME/.ssh/id_ed25519"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# --- packages ---------------------------------------------------------------
if ! command -v pacman &>/dev/null; then
  echo "This script currently only supports Arch (pacman not found)." >&2
  exit 1
fi

log "Installing packages"
sudo pacman -S --needed --noconfirm \
  git stow zsh tmux neovim openssh github-cli \
  zoxide fzf zsh-autosuggestions zsh-syntax-highlighting \
  fd tree trash-cli lazygit flatpak

# --- submodules -------------------------------------------------------------
log "Initializing submodules"
git -C "$DOTFILES_DIR" submodule update --init --recursive

# --- stow -------------------------------------------------------------------
# Move real files/dirs out of the way; stow refuses to overwrite them.
backup_if_real() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    log "Backing up existing $target to $target.bak"
    mv "$target" "$target.bak"
  fi
}
backup_if_real "$HOME/.zshrc"
backup_if_real "$HOME/.p10k.zsh"
backup_if_real "$HOME/.config/tmux"
backup_if_real "$HOME/.config/nvim"
backup_if_real "$HOME/.config/powerlevel10k"
backup_if_real "$HOME/.pi/agent/settings.json"

# Keep Pi credentials, sessions, and caches outside the dotfiles worktree.
# Without this directory, Stow may fold ~/.pi into the pi package.
mkdir -p "$HOME/.pi/agent"

log "Stowing packages: ${STOW_PACKAGES[*]}"
stow -d "$DOTFILES_DIR" -t "$HOME" -R "${STOW_PACKAGES[@]}"

# --- ssh key ----------------------------------------------------------------
if [[ ! -f "$SSH_KEY" ]]; then
  log "Generating SSH key ($SSH_KEY)"
  ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$(whoami)@$(hostname)"
else
  log "SSH key already exists, skipping generation"
fi

# --- github -----------------------------------------------------------------
log "Authenticating with GitHub"
if ! gh auth status &>/dev/null; then
  gh auth login --git-protocol ssh --hostname github.com --scopes admin:public_key
else
  # Make sure the existing token may manage SSH keys.
  gh auth status 2>/dev/null | grep -q 'admin:public_key' ||
    gh auth refresh --hostname github.com --scopes admin:public_key
fi

if gh ssh-key list 2>/dev/null | grep -qF "$(awk '{print $2}' "$SSH_KEY.pub")"; then
  log "SSH key already registered on GitHub"
else
  log "Adding SSH key to GitHub"
  gh ssh-key add "$SSH_KEY.pub" --title "$(whoami)@$(hostname)"
fi

# Switch the repo remote to SSH so pushes use the new key.
remote_url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
if [[ "$remote_url" == https://github.com/* ]]; then
  log "Switching origin remote to SSH"
  git -C "$DOTFILES_DIR" remote set-url origin \
    "git@github.com:${remote_url#https://github.com/}"
fi

# --- login shell ------------------------------------------------------------
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  log "Making zsh the login shell"
  chsh -s "$(command -v zsh)"
fi

log "Done. Start a new terminal (or run 'zsh') to use the new setup."
