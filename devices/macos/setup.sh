#!/usr/bin/env bash
#
# macOS-specific settings on top of the shared dotfiles.
# Run from the cloned repo:  ./devices/macos/setup.sh [--defaults]
#
# --defaults  applies the sensible `defaults`/Dock tweaks below.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Installing macOS fish config"
mkdir -p "$HOME/.config"
cp -rn "$REPO/devices/macos/setup/fish" "$HOME/.config/"
ln -sfn "$REPO/devices/macos/setup/starship.toml" "$HOME/.config/starship.toml"

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

echo "=== macOS setup complete ==="
