#!/usr/bin/env bash
#
# Links the dotfiles that are identical on every OS, straight from dots/.
# Used by devices/linux/setup.sh and the macOS bootstrap.
#
# run:  ./devices/shared/setup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$HOME/.config"
for c in kitty fastfetch btop micro; do
  ln -sfn "$REPO/dots/$c" "$HOME/.config/$c"
done
ln -sfn "$REPO/dots/starship.toml" "$HOME/.config/starship.toml"

echo "shared dotfiles linked from $REPO/dots/"
