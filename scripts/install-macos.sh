#!/usr/bin/env bash
#
# kaan's macOS bootstrap (not yet applied — placeholder for the future
# third machine). When that Mac arrives:
#
#   1. Install the Command Line Tools:  xcode-select --install
#   2. Run this script. It installs Homebrew, clones the nix-config repo
#      and the dotfiles fork, and links the shared dotfiles (kitty,
#      fastfetch) from ~/dotfiles.
#   3. mac/setup/ holds macOS-specific config (fish, starship, Dock,
#      defaults); anything that also belongs on Linux goes in ~/dotfiles.

set -euo pipefail

REPO_URL=https://github.com/kaanreal/nix.git
REPO_DIR="$HOME/nix-config"
DOTFILES_URL="${DOTFILES_URL:-https://github.com/kaanreal/dotfiles.git}"
DOTFILES_DIR="$HOME/dotfiles"

echo "==> Installing Homebrew (if missing)"
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Cloning nix-config repo"
if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

echo "==> Cloning dotfiles repo"
if [ ! -d "$DOTFILES_DIR" ]; then
  git clone "$DOTFILES_URL" "$DOTFILES_DIR"
fi

echo "==> Linking shared dotfiles"
mkdir -p "$HOME/.config"
ln -sfn "$DOTFILES_DIR/kitty"     "$HOME/.config/kitty"
ln -sfn "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch"

echo "==> Installing shared CLI tools"
brew install --quiet \
  git fish starship fastfetch btop eza ripgrep bat zoxide fzf \
  neovim vim tmux htop

echo "==> Installing macOS dotfiles"
mkdir -p "$HOME/.config"
cp -rn "$REPO_DIR/mac/setup/fish"         "$HOME/.config/"
ln -sfn "$REPO_DIR/mac/setup/starship.toml" "$HOME/.config/starship.toml"

echo
echo "=== macOS bootstrap complete ==="
echo "finish in Terminal settings: set the shell to /opt/homebrew/bin/fish"
echo "then run:  ~/nix-config/mac/setup.sh --defaults"
