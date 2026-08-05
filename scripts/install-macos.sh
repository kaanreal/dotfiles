#!/usr/bin/env bash
#
# kaan's macOS bootstrap — one-shot on a fresh Mac:
#
#   1. Install the Command Line Tools (xcode-select --install)
#   2. Run this script: Homebrew, the cozy-home repo, and all shared links.
#   3. Run ~/cozy-home/devices/macos/setup.sh --defaults for the macOS
#      specifics (fish as login shell, Dock/Finder defaults).
#
# All dotfiles live centrally in dots/ and get symlinked into ~/.config —
# the same files NixOS uses, kept in one place.

set -euo pipefail

REPO_URL=https://github.com/kaanreal/cozy-home.git
REPO_DIR="$HOME/cozy-home"

echo "==> Installing Homebrew (if missing)"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Cloning cozy-home repo"
if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

echo "==> Linking shared dotfiles from dots/"
"$REPO_DIR/devices/shared/setup.sh"

echo
echo "=== macOS bootstrap complete ==="
echo "next:  ~/cozy-home/devices/macos/setup.sh --defaults"
