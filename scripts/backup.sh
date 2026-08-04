#!/usr/bin/env bash
#
# Snapshot the whole cozy-home repo (git history included) into ~/.backups/.
# Keeps the last 5 tarballs.
#
# run:  ./scripts/backup.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${BACKUP_DIR:-$HOME/.backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$DEST/cozy-home-$STAMP.tar.gz"

mkdir -p "$DEST"
tar czf "$OUT" -C "$(dirname "$REPO")" "$(basename "$REPO")"

# prune old backups (keep 5)
ls -1t "$DEST"/cozy-home-*.tar.gz 2>/dev/null | tail -n +6 | xargs -r rm -f

echo "backed up to $OUT"
ls -1t "$DEST"/cozy-home-*.tar.gz 2>/dev/null
