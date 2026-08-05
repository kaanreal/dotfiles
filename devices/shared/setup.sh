#!/usr/bin/env bash
#
# Links the dotfiles that are identical on every OS, straight from dots/.
# Used by NixOS (via nix/home/kaan/dotfiles.nix) and by the Linux/macOS
# setup scripts. Safe to re-run.
#
# run:  ./devices/shared/setup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"

# BSD `ln -sfn` puts the link *inside* an existing directory instead of
# replacing it, so move a real dir aside (as a .pre-cozy backup) first.
link_dir() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm -f "$dst"
  elif [ -d "$dst" ]; then
    mv "$dst" "$dst.pre-cozy"
  fi
  ln -s "$src" "$dst"
}

mkdir -p "$HOME/.config"
for c in fish kitty fastfetch btop micro; do
  link_dir "$REPO/dots/$c" "$HOME/.config/$c"
done

ln -sfn "$REPO/dots/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$REPO/dots/git/ignore_global" "$HOME/.gitignore_global"

echo "shared dotfiles linked from $REPO/dots/"
