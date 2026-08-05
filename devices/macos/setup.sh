#!/usr/bin/env bash
#
# kaan's macOS setup — links the central dotfiles from dots/ and applies
# macOS-specific tweaks. Idempotent: safe to re-run any time.
#
# run:  ./devices/macos/setup.sh [--defaults]
#
# --defaults  also applies the sensible `defaults`/Dock tweaks below.
#             (usually pass this on first setup; afterwards plain re-runs
#              only refresh the symlinks and don't touch your settings)

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Linking shared dotfiles from dots/"
"$REPO/devices/shared/setup.sh"

echo "==> Linking macOS git config"
ln -sfn "$REPO/dots/git/config"        "$HOME/.gitconfig"
ln -sfn "$REPO/dots/git/ignore_global" "$HOME/.gitignore_global"

echo "==> Installing CLI tools (idempotent)"
if command -v brew >/dev/null; then
  brew install --quiet \
    git fish starship fastfetch btop eza ripgrep bat zoxide fzf lazygit \
    neovim vim tmux htop
else
  echo "   Homebrew missing — run scripts/install-macos.sh first"
fi

echo "==> Making fish the default shell"
if command -v fish >/dev/null; then
  FISH_BIN="$(command -v fish)"
  if [[ "$(dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}')" != "$FISH_BIN" ]]; then
    grep -qxF "$FISH_BIN" /etc/shells 2>/dev/null || echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$FISH_BIN" 2>/dev/null \
      || echo "   set fish as your login shell manually: Terminal > Settings > Shell"
  fi
else
  echo "   fish not installed — run scripts/install-macos.sh first"
fi

if [[ "${1:-}" == "--defaults" ]]; then
  echo "==> Applying macOS defaults"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock tilesize -int 42
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  killall Dock 2>/dev/null || true
fi

echo
echo "=== macOS setup complete ==="
echo "open a new terminal — fish is running your central ~/cozy-home dotfiles."
