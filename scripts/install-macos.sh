#!/usr/bin/env bash
#
# kaan's macOS bootstrap — one-shot on a fresh Mac:
#
#   1. Install the Command Line Tools (xcode-select --install)
#   2. Run this script: Homebrew and the cozy-home repo.
#   3. Run ~/cozy-home/devices/macos/setup.sh --defaults for the macOS
#      specifics (symlinks, brew CLI tools, fish as login shell, Dock/Finder
#      defaults).
#
# macOS keeps its own independent dotfiles in devices/macos/dots/ and does
# not share the Linux dots/ that NixOS uses.

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

echo "==> Repo cloned — next step links dotfiles"
echo "    run:  ~/cozy-home/devices/macos/setup.sh --defaults"
