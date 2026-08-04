#!/usr/bin/env bash
#
# Pull upstream Caelestia dotfiles changes into dots/ (vendored subtree).
#
# Safe by design: refuses to run on a dirty/staged tree, never force-resets,
# never silently prefers upstream over your local edits — if a file conflicts
# it stops and prints the files that need your attention.
#
# This is the fish function `dots-update` in a plain shell:
#   git fetch caelestia-upstream && git subtree pull --prefix dots ...
#
# run:  ./scripts/update-caelestia.sh

set -euo pipefail

cd "$(cd "$(dirname "$0")/.." && pwd)"   # repo root

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not a git repository (run from ~/cozy-home)" >&2
  exit 1
fi

if ! git diff --quiet; then
  echo "error: uncommitted changes — commit or stash them first" >&2
  exit 1
fi
if ! git diff --cached --quiet; then
  echo "error: staged changes — commit or stash them first" >&2
  exit 1
fi

echo "==> fetching caelestia-upstream"
git fetch caelestia-upstream

echo "==> merging upstream into dots/"
git subtree pull --prefix dots caelestia-upstream main
# on conflict `set -e` stops here; run `git status` to see dots/ conflicts

echo
echo "=== dots updated ==="
echo "Run 'hyprctl reload' and restart the shell, then 'save' to push."
