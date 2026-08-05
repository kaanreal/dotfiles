#!/usr/bin/env bash
#
# Links the dotfiles that are identical on every OS, straight from dots/.
# Used by NixOS (via nix/home/kaan/dotfiles.nix) and by the Linux/macOS
# setup scripts.
#
# run:  ./devices/shared/setup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$HOME/.config"
for c in fish kitty fastfetch btop micro; do
  ln -sfn "$REPO/dots/$c" "$HOME/.config/$c"
done
ln -sfn "$REPO/dots/starship.toml" "$HOME/.config/starship.toml"

# Global gitignore (never the user identity — that's linked per-OS).
ln -sfn "$REPO/dots/git/ignore_global" "$HOME/.gitignore_global"

echo "shared dotfiles linked from $REPO/dots/"
