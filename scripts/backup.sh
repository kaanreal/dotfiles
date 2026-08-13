#!/usr/bin/env bash
#
# Snapshot the whole dotfiles repo (git history included) into ~/.backups/.
# Keeps the last 5 tarballs.
#
# run:  ./scripts/backup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${BACKUP_DIR:-$HOME/.backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$DEST/dotfiles-$STAMP.tar.gz"

mkdir -p "$DEST"
tar czf "$OUT" -C "$(dirname "$REPO")" "$(basename "$REPO")"

# Prune old backups without relying on GNU-specific `xargs -r`.
count=0
while IFS= read -r backup; do
  count=$((count + 1))
  if (( count > 5 )); then
    rm -f -- "$backup"
  fi
done < <(find "$DEST" -maxdepth 1 -type f -name 'dotfiles-*.tar.gz' -print | sort -r)

echo "backed up to $OUT"
ls -1t "$DEST"/dotfiles-*.tar.gz 2>/dev/null
