#!/usr/bin/env bash
#
# Fresh NixOS install from this repo.
#
#  1. Install NixOS from the graphical ISO (partition + base system).
#  2. Copy the machine's generated /etc/nixos/hardware-configuration.nix
#     into hosts/nixos-desktop/hardware-configuration.nix.
#  3. Run this script as the user:  ./scripts/install-nixos.sh
#
# It clones cozy-home and builds/activates the system. Afterwards the
# daily-driver commands (rebuild / update / save) work via `nh os switch`.

set -euo pipefail

REPO_URL=https://github.com/kaanreal/cozy-home.git
REPO_DIR=/home/kaan/cozy-home

if [[ $EUID -eq 0 ]]; then
  echo "run this as the user, not root" >&2
  exit 1
fi

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "==> Cloning cozy-home"
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

echo "==> Building + activating the system (this takes a while)"
nixos-rebuild switch --flake .#nixos

echo
echo "=== NixOS ready ==="
echo "Next: set a hostname/user password if needed, then everything lives"
echo "in ~/cozy-home — run 'rebuild' / 'update' / 'save' from any shell."
