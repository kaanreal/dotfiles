#!/usr/bin/env bash
#
# kaan's macOS bootstrap (not yet applied — placeholder for the future
# third machine). When that Mac arrives:
#
#   1. Install the Command Line Tools:  xcode-select --install
#   2. Run this script. It installs Homebrew, clones the cozy-home repo
#      and links the shared dotfiles (kitty, fastfetch) from dots/.
#   3. devices/macos/setup/ holds macOS-specific config (fish, starship,
#      Dock, defaults); anything that also belongs on Linux goes in dots/.

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
mkdir -p "$HOME/.config"
ln -sfn "$REPO_DIR/dots/kitty"      "$HOME/.config/kitty"
ln -sfn "$REPO_DIR/dots/fastfetch"  "$HOME/.config/fastfetch"
ln -sfn "$REPO_DIR/dots/starship.toml" "$HOME/.config/starship.toml"

echo "==> Installing shared CLI tools"
brew install --quiet \
  git fish starship fastfetch btop eza ripgrep bat zoxide fzf \
  neovim vim tmux htop

echo "==> Installing macOS dotfiles"
mkdir -p "$HOME/.config"
cp -rn "$REPO_DIR/devices/macos/setup/fish"          "$HOME/.config/"
ln -sfn "$REPO_DIR/devices/macos/setup/starship.toml" "$HOME/.config/starship.toml"

echo
echo "=== macOS bootstrap complete ==="
echo "finish in Terminal settings: set the shell to /opt/homebrew/bin/fish"
echo "then run:  ~/cozy-home/devices/macos/setup.sh --defaults"
